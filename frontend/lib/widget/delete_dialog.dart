import 'package:flutter/material.dart';

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({
    Key? key,
    this.icon,
    required this.onBarrierTap,
    required this.title,
    this.body,
    this.caption,
    required this.buttons,
  }) : super(key: key);

  final Widget? icon;
  final String? body;
  final String title;
  final String? caption;
  final Function() onBarrierTap;
  final List<DeleteDialogButton> buttons;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onBarrierTap();
      },
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              constraints: const BoxConstraints(maxWidth: (305)),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular((10)),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                      spreadRadius: 0,
                      color: Colors.black.withOpacity(0.08),
                    )
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  const Row(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: (19),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          body ?? '',
                          textAlign: TextAlign.left,
                        ),
                        if (caption != null) ...[
                          const SizedBox(height: 20),
                          Text(
                            caption ?? '',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              height: 1.3,
                              color: Colors.grey,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: buttons[0],
                        ),
                        if (buttons.length == 2) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: buttons[1],
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DeleteDialogButton extends StatelessWidget {
  const DeleteDialogButton(
      {Key? key,
      required this.onTap,
      required this.text,
      required this.backgroundColor,
      required this.textColor})
      : super(key: key);
  final Function() onTap;
  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: (50),
        padding: const EdgeInsets.symmetric(horizontal: (20)),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular((10)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
