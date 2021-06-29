FROM nginxinc/nginx-unprivileged:1.20

COPY site/* /usr/share/nginx/html/
