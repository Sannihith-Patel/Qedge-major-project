FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy static files from a remote URL
COPY ost-magazine .  /usr/share/nginx/html/      #the source code is avil from git repo its
                                                                                        #scm also in my git repo it’s the path .
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
