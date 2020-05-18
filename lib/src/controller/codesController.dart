import 'package:trailock/src/model/codeModel.dart';
import 'package:trailock/src/provider/dataBase.dart';

class CodesController {
  final String table = "codes";

  DataBaseTrailock con = new DataBaseTrailock();

  Future<List<CodeModel>> index() async {
    var db = await con.db;
    var res = await db.query(table);
    List<CodeModel> list =
        res.isNotEmpty ? res.map((d) => CodeModel.fromJson(d)).toList() : [];
    return list;
  }

  Future<int> save(CodeModel padLock) async {
    var db = await con.db;
    return await db.insert(table, padLock.toJson());
  }

  Future<int> deleteTable() async {
    var db = await con.db;
    return await db.delete(table);
  }
}
