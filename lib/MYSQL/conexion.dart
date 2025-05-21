import 'package:mysql1/mysql1.dart';

Future<MySqlConnection> conectarDB() async {
  final settings = ConnectionSettings(
    host: 'localhost', // O IP si estás en red
    port: 3306,
    user: 'root', // Tu usuario
    password: '123456', // Tu contraseña
    db: 'universal', // Tu base de datos
  );

  return await MySqlConnection.connect(settings);
  

}
