import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class ListeModuleGroupe extends StatefulWidget {
  const ListeModuleGroupe({Key? key}) : super(key: key);

  @override
  State<ListeModuleGroupe> createState() => _ListeModuleGroupeState();
}

class _ListeModuleGroupeState extends State<ListeModuleGroupe> {
  List<Map<String, dynamic>> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final result = await DatabaseHelper.instance.getModulesGrouped();
    setState(() {
      data = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          "Modules & Groupes",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? const Center(child: Text("Aucune affectation trouvée"))
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          // 🔹 TAILLES AUGMENTÉES
                          headingRowHeight: 72,
                          dataRowHeight: 72,
                          columnSpacing: 120,
                          horizontalMargin: 40,

                          headingRowColor:
                              MaterialStateProperty.all(Colors.blueAccent),

                          columns: const [
                            DataColumn(
                              label: Text(
                                "MODULE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "GROUPE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],

                          rows: data.map((e) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.blue.shade100,
                                        child: const Icon(
                                          Icons.book,
                                          color: Colors.blueAccent,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        e['moduleName'],
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          color: Colors.green.shade400),
                                    ),
                                    child: Text(
                                      e['groupName'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
