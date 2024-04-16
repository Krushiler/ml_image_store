enum Routes {
  auth('auth'),
  folders('folders'),
  folder('folder'),
  createImage('createImage'),
  image('image'),
  ;

  final String name;

  const Routes(this.name);
}
