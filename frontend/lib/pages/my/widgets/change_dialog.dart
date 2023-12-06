import 'package:beautyminder/pages/my/widgets/default_dialog.dart';
import 'package:flutter/material.dart';

class ChangeDialog extends StatefulWidget {
  const ChangeDialog({
    Key? key,
    this.icon,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final Widget? icon;
  final String title;
  final String subtitle;

  @override
  State<ChangeDialog> createState() => _ChangeDialogState();
}

class _ChangeDialogState extends State<ChangeDialog> {
  final _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 20),
                Center(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, null),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              height: 45,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextFormField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: widget.subtitle,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  cursorColor: Colors.grey,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            DefaultDialogButton(
              onTap: () => Navigator.pop(context, _textEditingController.text),
              backgroundColor: const Color(0xFFFF820E),
              text: '변경하기',
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
