write_files:
-   content: |
        [general]
        state_file= /var/awslogs/agent-state

        [/var/log/secure]
        file = /var/log/secure
        log_group_name = ${ws_log_group}
        log_stream_name = {instance_id}/ssh.log
        datetime_format = %d/%b/%Y:%H:%M:%S

        [/var/log/audit]
        file = /var/log/audit/audit.log
        log_group_name = ${ws_log_group}
        log_stream_name = {instance_id}/audit.log
        datetime_format = %d/%b/%Y:%H:%M:%S
    path: ${ssh_access_config_location}
    owner: root:root
    permissions: '0644'