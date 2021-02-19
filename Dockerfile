#FROM httpd:2.4
#COPY ./static-html/ /usr/local/apache2/htdocs/

FROM nginx
COPY static-html/index.html /usr/share/nginx/html/index.html