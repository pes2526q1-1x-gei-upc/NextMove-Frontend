import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<String>? onChanged;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Botón de adjuntar (opcional, para futuro)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                // TODO: Implementar adjuntar archivos/imágenes
              },
              color: theme.colorScheme.primary,
            ),

            // Campo de texto
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onChanged: onChanged,
                onSubmitted: (_) => onSend(),
              ),
            ),

            const SizedBox(width: 8),

            // Botón de enviar
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                final hasText = value.text.trim().isNotEmpty;
                
                return IconButton(
                  icon: Icon(
                    hasText ? Icons.send : Icons.mic,
                  ),
                  onPressed: hasText
                      ? onSend
                      : () {
                          // TODO: Implementar grabación de voz
                        },
                  color: theme.colorScheme.primary,
                  style: IconButton.styleFrom(
                    backgroundColor: hasText
                        ? theme.colorScheme.primaryContainer
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}