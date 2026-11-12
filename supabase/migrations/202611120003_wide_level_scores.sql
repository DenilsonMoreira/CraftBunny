begin;
-- Keep historical records and 0.3.4 clients at their original 139-carrot cap.
alter table craftbunny_private.run_sessions drop constraint run_sessions_game_version_check;
alter table craftbunny_private.run_sessions add constraint run_sessions_game_version_check check(game_version in ('0.3.4','0.4.0'));
alter table craftbunny_private.scores drop constraint scores_game_version_check;
alter table craftbunny_private.scores add constraint scores_game_version_check check(game_version in ('0.3.4','0.4.0'));
alter table craftbunny_private.scores drop constraint scores_carrots_check;
alter table craftbunny_private.scores add constraint scores_carrots_check check(carrots between 1 and (case when game_version='0.4.0' then 200 else 139 end));
create or replace function public.cb_start_run(p_id uuid,p_token_hash text,p_client_hash text,p_game_version text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare total_hour integer; total_minute integer; expiry timestamptz;
begin
 if p_id is null or p_token_hash is null or p_token_hash !~ '^[0-9a-f]{64}$'
   or p_client_hash is null or p_client_hash !~ '^[0-9a-f]{64}$'
   or (p_game_version is null or p_game_version not in ('0.3.4','0.4.0')) then
  raise exception 'invalid_run';
 end if;
 perform pg_advisory_xact_lock(hashtextextended(p_client_hash,0));
 select count(*), count(*) filter(where started_at > now()-interval '1 minute')
 into total_hour,total_minute from craftbunny_private.run_sessions
 where client_hash=p_client_hash and started_at > now()-interval '1 hour';
 if total_hour >= 30 or total_minute >= 6 then raise exception 'rate_limited'; end if;
 -- Bounded retention for expired sessions and hashed network identifiers.
 delete from craftbunny_private.run_sessions r
 where r.expires_at < now()-interval '1 day'
 and not exists(select 1 from craftbunny_private.scores s where s.run_id=r.id);
 update craftbunny_private.run_sessions set client_hash=repeat('0',64)
 where started_at < now()-interval '1 day' and client_hash<>repeat('0',64);
 insert into craftbunny_private.run_sessions(id,token_hash,client_hash,game_version)
 values(p_id,p_token_hash,p_client_hash,p_game_version) returning expires_at into expiry;
 return jsonb_build_object('run_id',p_id,'expires_at',expiry);
end $$;

create or replace function public.cb_submit_score(p_id uuid,p_token_hash text,p_initials text,p_carrots integer,p_won boolean,p_duration_ms integer,p_game_version text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare run craftbunny_private.run_sessions; saved craftbunny_private.scores; elapsed numeric;
begin
 if p_initials is null or p_initials !~ '^[A-Z]{3}$'
   or p_carrots is null or p_carrots not between 1 and (case when p_game_version='0.4.0' then 200 else 139 end) or p_won is null
   or p_duration_ms is null or p_duration_ms not between 1000 and 21600000
   or (p_game_version is null or p_game_version not in ('0.3.4','0.4.0')) then raise exception 'invalid_score'; end if;
 select * into run from craftbunny_private.run_sessions where id=p_id for update;
 if not found or p_token_hash is null or run.token_hash<>p_token_hash then raise exception 'invalid_run'; end if;
 select * into saved from craftbunny_private.scores where run_id=p_id;
 if found then
  if saved.initials<>p_initials or saved.carrots<>p_carrots or saved.won<>p_won
    or saved.duration_ms<>p_duration_ms or saved.game_version<>p_game_version then raise exception 'conflicting_result'; end if;
  return jsonb_build_object('accepted',true,'duplicate',true,'run_id',p_id);
 end if;
 if run.expires_at < now() then raise exception 'expired_run'; end if;
 elapsed := extract(epoch from (now()-run.started_at))*1000;
 if run.game_version<>p_game_version or elapsed<1000 or p_duration_ms>elapsed+5000
   or (p_won and p_duration_ms<45000) then raise exception 'implausible_run'; end if;
 insert into craftbunny_private.scores(run_id,initials,carrots,won,duration_ms,game_version)
 values(p_id,p_initials,p_carrots,p_won,p_duration_ms,p_game_version);
 return jsonb_build_object('accepted',true,'duplicate',false,'run_id',p_id);
end $$;


revoke all on function public.cb_start_run(uuid,text,text,text) from public,anon,authenticated;
revoke all on function public.cb_submit_score(uuid,text,text,integer,boolean,integer,text) from public,anon,authenticated;
grant execute on function public.cb_start_run(uuid,text,text,text) to service_role;
grant execute on function public.cb_submit_score(uuid,text,text,integer,boolean,integer,text) to service_role;
notify pgrst, 'reload schema';
commit;
