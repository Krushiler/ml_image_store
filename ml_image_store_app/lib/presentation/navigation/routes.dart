enum Routes {
  auth('auth'),
  folders('folders'),
  folder('folder'),
  createImage('createImage'),
  image('image'),
  settings('settings'),
  ;

  final String name;

  const Routes(this.name);
}
