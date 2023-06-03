import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kindah/models/account.dart';
import 'package:kindah/models/admin.dart';
import 'package:kindah/models/product.dart';
import 'package:kindah/models/school.dart';
import 'package:kindah/models/uniform.dart';

class UpdateAdminInfo {
  Future<void> updateAdminCount(Map<String, dynamic> map) async {
    await FirebaseFirestore.instance
        .collection("admins")
        .doc("0001")
        .update(map);
  }

  Future<Admin> getAdminInfo() async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection("admins").doc("0001").get();

    Admin admin = Admin.fromDocument(documentSnapshot);

    return admin;
  }

  Future<void> updateUserCount(Account account, bool isAdd) async {
    Admin admin = await getAdminInfo();
    int tailorCount = admin.tailors!;
    int fabricCount = admin.fabricCutters!;
    int shopAttendantsCount = admin.shopAttendants!;
    int finisherCount = admin.finishers!;

    switch (account.userRole) {
      case "tailor":
        await updateAdminCount({
          "tailors": isAdd ? tailorCount + 1 : tailorCount - 1,
        });
        break;
      case "fabric_cutter":
        await updateAdminCount({
          "fabricCutters": isAdd ? fabricCount + 1 : fabricCount - 1,
        });
        break;
      case "shop_attendant":
        await updateAdminCount({
          "shopAttendants":
              isAdd ? shopAttendantsCount + 1 : shopAttendantsCount - 1,
        });
        break;
      case "finisher":
        await updateAdminCount({
          "finishers": isAdd ? finisherCount + 1 : finisherCount - 1,
        });
        break;
    }
  }

  Future<void> updateSchoolCount(School school, bool isAdd) async {
    Admin admin = await getAdminInfo();
    int schoolsCount = admin.schools!;

    await updateAdminCount({
      "schools": isAdd ? schoolsCount + 1 : schoolsCount - 1,
    });
  }

  Future<void> updateUniformsCount(Uniform uniform, bool isAdd) async {
    Admin admin = await getAdminInfo();
    int uniformsCount = admin.uniforms!;

    await updateAdminCount({
      "uniforms": isAdd ? uniformsCount + 1 : uniformsCount - 1,
    });
  }

  Future<void> updateProductsCount(Product product, bool isAdd) async {
    Admin admin = await getAdminInfo();
    int productsCount = admin.products!;

    await updateAdminCount({
      "products": isAdd ? productsCount + 1 : productsCount - 1,
    });
  }
}
