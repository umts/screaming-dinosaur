  INFO [4eb5743f] Running /usr/bin/env .kamal/hooks/pre-connect as benmelz@localhost
  INFO [4eb5743f] Finished in 3.021 seconds with exit status 0 (successful).
Get most recent version available as an image...
Launching command with version latest from new container...
  INFO [72a59681] Running docker login ghcr.io -u [REDACTED] -p [REDACTED] on afs-umts-web4.admin.umass.edu
  INFO [72a59681] Finished in 0.808 seconds with exit status 0 (successful).
  INFO [4823a440] Running docker run --rm --name screaming_dinosaur-web-exec-latest-14d1f7 --network kamal --env TZ="America/New_York" --env-file .kamal/apps/screaming_dinosaur/env/roles/web.env --log-opt max-size="10m" --volume screaming_dinosaur_log:/rails/log --volume screaming_dinosaur_storage:/rails/storage ghcr.io/umts/screaming-dinosaur:latest bash "SCHEMA=/dev/stdout /rails/bin/rails db:schema:dump" on afs-umts-web4.admin.umass.edu
  [31mERROR (SSHKit::Runner::ExecuteError): Exception while executing on web: Exception while executing on host afs-umts-web4.admin.umass.edu: docker exit status: 127
docker stdout: Nothing written
docker stderr: bash: SCHEMA=/dev/stdout /rails/bin/rails db:schema:dump: No such file or directory
[0m
