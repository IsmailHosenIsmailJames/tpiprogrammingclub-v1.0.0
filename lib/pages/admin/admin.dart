import 'package:flutter/material.dart';
import 'package:tpiprogrammingclub/pages/admin/delete_post.dart';
import 'package:tpiprogrammingclub/pages/admin/pending_post.dart';
import 'package:tpiprogrammingclub/pages/admin/update_rank.dart';
import 'package:tpiprogrammingclub/pages/home/home_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: elevatedStyle,
                minimumSize: const Size(270, 40),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PendingPost(),
                  ),
                );
              },
              child: const Text('All Pending Post'),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: elevatedStyle,
                minimumSize: const Size(270, 40),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeletePost(),
                  ),
                );
              },
              child: const Text('Delete a Post'),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: elevatedStyle,
                minimumSize: const Size(270, 40),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UpdateRank(),
                  ),
                );
              },
              child: const Text('Update All The Rank'),
            ),
          ],
        ),
      ),
    );
  }
}
