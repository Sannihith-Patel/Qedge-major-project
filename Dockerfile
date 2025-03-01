FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy static files from a remote URL
COPY templatemo_511_journey .  /usr/share/nginx/html/   
                                                                          
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
