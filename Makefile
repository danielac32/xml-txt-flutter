
#python3 -m http.server 8080
#npm install -g http-server
#http-server http-server -p 3000
#cloudflared tunnel --url http://0.0.0.0:8080
run:
	flutter run -d linux

build:
	flutter build web

runweb:
		@echo "Building Flutter web app..."
		flutter build web
		@echo "\nStarting HTTP server on port 1234..."
		cd build/web &&  http-server -p 1234 --rewrite "/.* /index.html" #cd build/web && python3 -m http.server 8080

start:
	  cd build/web &&  http-server -p 1234 --rewrite "/.* /index.html"