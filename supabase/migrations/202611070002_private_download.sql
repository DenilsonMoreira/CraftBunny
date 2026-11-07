begin;
-- Independent of leaderboard data. Never deletes or modifies scores.
create table craftbunny_private.download_attempts (
 client_hash text not null check(client_hash ~ '^[0-9a-f]{64}$'),
 minute_bucket timestamptz not null,
 attempts integer not null check(attempts>0),
 primary key(client_hash,minute_bucket)
);
create table craftbunny_private.download_codes (
 secret_tag text not null check(secret_tag ~ '^[0-9a-f]{64}$'),
 time_step bigint not null,
 apk_version text not null check(apk_version ~ '^[0-9]+[.][0-9]+[.][0-9]+[-a-zA-Z0-9.]*$'),
 used_at timestamptz not null default now(),
 primary key(secret_tag,time_step)
);
alter table craftbunny_private.download_attempts enable row level security;
alter table craftbunny_private.download_codes enable row level security;
revoke all on craftbunny_private.download_attempts,craftbunny_private.download_codes from public,anon,authenticated;

create function public.cb_download_attempt(p_client_hash text)
returns jsonb language plpgsql security definer set search_path='' as $$
declare minute_count integer; hour_count integer;
begin
 if p_client_hash is null or p_client_hash !~ '^[0-9a-f]{64}$' then raise exception 'download_rate_limited'; end if;
 perform pg_advisory_xact_lock(hashtextextended('cb-download:'||p_client_hash,0));
 select coalesce(sum(attempts),0),coalesce(sum(attempts) filter(where minute_bucket=date_trunc('minute',now())),0)
 into hour_count,minute_count from craftbunny_private.download_attempts
 where client_hash=p_client_hash and minute_bucket>now()-interval '1 hour';
 if minute_count>=5 or hour_count>=20 then raise exception 'download_rate_limited'; end if;
 delete from craftbunny_private.download_attempts where minute_bucket<now()-interval '1 day';
 delete from craftbunny_private.download_codes where used_at<now()-interval '1 day';
 insert into craftbunny_private.download_attempts(client_hash,minute_bucket,attempts)
 values(p_client_hash,date_trunc('minute',now()),1)
 on conflict(client_hash,minute_bucket) do update set attempts=craftbunny_private.download_attempts.attempts+1;
 return jsonb_build_object('allowed',true);
end $$;

create function public.cb_download_use_code(p_secret_tag text,p_time_step bigint,p_apk_version text)
returns jsonb language plpgsql security definer set search_path='' as $$
begin
 if p_secret_tag is null or p_secret_tag !~ '^[0-9a-f]{64}$'
 or p_time_step is null or abs(p_time_step-floor(extract(epoch from now())/30)::bigint)>1
 or p_apk_version is null or length(p_apk_version)>32
 or p_apk_version !~ '^[0-9]+[.][0-9]+[.][0-9]+[-a-zA-Z0-9.]*$' then raise exception 'download_otp_used'; end if;
 insert into craftbunny_private.download_codes(secret_tag,time_step,apk_version)
 values(p_secret_tag,p_time_step,p_apk_version) on conflict do nothing;
 if not found then raise exception 'download_otp_used'; end if;
 return jsonb_build_object('allowed',true);
end $$;
revoke all on function public.cb_download_attempt(text) from public,anon,authenticated;
revoke all on function public.cb_download_use_code(text,bigint,text) from public,anon,authenticated;
grant execute on function public.cb_download_attempt(text) to service_role;
grant execute on function public.cb_download_use_code(text,bigint,text) to service_role;
commit;
