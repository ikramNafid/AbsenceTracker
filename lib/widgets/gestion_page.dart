import 'package:flutter/material.dart';

class GestionPage extends StatelessWidget {
  final String title;
  final String searchHint;
  final TextEditingController searchController;
  final List<Map<String, dynamic>> items;

  final VoidCallback? onImportCSV;
  final VoidCallback onAdd;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(int) onDelete;

  const GestionPage({
    super.key,
    required this.title,
    required this.searchHint,
    required this.searchController,
    required this.items,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    this.onImportCSV,
  });

  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color secondaryGray = Color(0xFFF3F6FB);
  static const Color cardColor = Colors.white;
  static const Color totalColor = Color(0xFF1E40AF); // bleu foncé pour le total

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryGray,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 4,
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Champ de recherche moderne
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3)),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: searchHint,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 📂 Bouton Import CSV stylé
            if (onImportCSV != null) ...[
              GestureDetector(
                onTap: onImportCSV,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [primaryBlue.withOpacity(0.85), primaryBlue]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.file_upload_outlined, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'Importer un fichier CSV',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Total des éléments stylé
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total : ${items.length}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: totalColor),
              ),
            ),

            const SizedBox(height: 16),

            // 📋 Liste des items sous forme de cartes avec scrollbar
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun élément trouvé',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : Scrollbar(
                      thumbVisibility: true,
                      thickness: 6,
                      radius: const Radius.circular(8),
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildItemCard(item);
                        },
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // ➕ Bouton Ajouter stylé avec gradient
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text(
                  'Ajouter',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  backgroundColor: primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Carte pour chaque item avec effet pro
  Widget _buildItemCard(Map<String, dynamic> item) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          title: Text(
            '${item['firstName']} ${item['lastName']}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            item['email'] ?? '',
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => onEdit(item),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(item['id']),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
