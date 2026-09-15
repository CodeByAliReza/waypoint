import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceTile extends StatelessWidget {
  final String resource;
  final int index;

  const ResourceTile({
    super.key,
    required this.resource,
    required this.index,
  });

  Future<void> _launch() async {
    final uri = Uri.parse(resource);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUrl = resource.startsWith('http://') || resource.startsWith('https://');

    return ListTile(
      leading: CircleAvatar(
        child: Text('${index + 1}'),
      ),
      title: Text(resource),
      trailing: isUrl ? const Icon(Icons.open_in_new) : null,
      onTap: isUrl ? _launch : null,
    );
  }
}
