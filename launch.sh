ps -ef | grep 'build/bin/server.dart' | grep -v grep | awk '{print $2}' | xargs -r kill -9

cd /home/krushiler/ml_image_store

git pull origin master

cd ml_image_store
dart pub get
dart run build_runner build
cd ..

cd ml_image_store_app
dart pub get
dart run build_runner build
flutter build web
cd ..

cd ml_image_store_server
dart pub get
dart_frog build
cd ..

sudo systemctl restart nginx
sudo systemctl restart ml_store_server.service
