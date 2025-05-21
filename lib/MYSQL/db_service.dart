import 'package:mysql1/mysql1.dart';

Future<bool> validarUsuario(String correo, String contrasena) async {
  final settings = ConnectionSettings(
    host: 'localhost',     // Cambia si usas red
    port: 3306,
    user: 'root',          // Tu usuario de MySQL
    password: '123456',    // Tu contraseña de MySQL
    db: 'universal',       // Tu base de datos
  );

  try {
    final conn = await MySqlConnection.connect(settings);
    var resultado = await conn.query(
      'SELECT * FROM usuarios WHERE correo = ? AND contrasena = ?',
      [correo, contrasena],
    );
    await conn.close();
    return resultado.isNotEmpty;
  } catch (e) {
    print('Error de conexión o consulta: $e');
    return false;
  }
}
