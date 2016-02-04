# install nginx mainline
nginx_pkg:
    pkgrepo.managed:
        - humanname: nginx
        - name: deb http://nginx.org/packages/mainline/ubuntu/ {{ grains['oscodename'] }} nginx
        - file: /etc/apt/sources.list.d/nginx.list
        - key_url: http://nginx.org/keys/nginx_signing.key
    pkg.installed:
        - name: nginx


/etc/nginx:
    file.recurse:
        - makedirs: True
        - source: salt://nginx-proxy-formula/etc
        - clean: True
        - template: jinja
        - watch_in:
            - service: nginx


{% for file in pillar['nginx-includes'] %}
include_{{ file }}:
    file.managed:
        - name: /etc/nginx/{{ file }}
        - mode: 600
        - makedirs: True
        - contents_pillar: nginx-includes:{{ file }}
        - watch_in:
            - service: nginx
{% endfor %}


/var/cache/nginx:
    file.directory:
        - user: www-data
        - group: www-data
        - recurse:
            - user
            - group


'nginx -t':
    cmd.run


nginx:
    service:
        - running
        - require:
            - pkg: nginx_pkg
            - cmd: 'nginx -t'


