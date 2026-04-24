import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/services/connectivity_service.dart';
import '/assets/theme/flutter_flow_theme.dart';

/// Widget que exibe um aviso visual quando não há conectividade
class OfflineWarningBanner extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets padding;

  const OfflineWarningBanner({
    super.key,
    this.message = 'Sem conexão com a internet',
    this.backgroundColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        if (connectivity.isOnline) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          color: backgroundColor ??
              FlutterFlowTheme.of(context).error.withValues(alpha: 0.9),
          padding: padding,
          child: Row(
            children: [
              Icon(
                Icons.wifi_off,
                color:
                    textColor ?? FlutterFlowTheme.of(context).onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        color: textColor ??
                            FlutterFlowTheme.of(context).onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget que desabilita um button quando sem internet e exibe tooltip
class OfflineAwareButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String offlineMessage;
  final ButtonStyle? style;

  const OfflineAwareButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.offlineMessage = 'Indisponível sem conexão',
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        return Tooltip(
          message: connectivity.isOffline ? offlineMessage : '',
          child: TextButton(
            onPressed: connectivity.isOnline ? onPressed : null,
            style: style,
            child: child,
          ),
        );
      },
    );
  }
}

/// Dialog simples para avisar que é preciso reconectar
void showOfflineDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.wifi_off,
            color: FlutterFlowTheme.of(context).error,
          ),
          const SizedBox(width: 12),
          const Text('Sem conexão'),
        ],
      ),
      content: Text(
        'Você precisa de uma conexão com a internet para usar esta funcionalidade.\n\nVerifique sua conexão WiFi ou dados móveis e tente novamente.',
        style: FlutterFlowTheme.of(context).bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Entendi',
            style: TextStyle(
              color: FlutterFlowTheme.of(context).primary,
            ),
          ),
        ),
      ],
    ),
  );
}
