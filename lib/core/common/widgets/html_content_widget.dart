import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlContentWidget extends StatelessWidget {
  final String htmlData;
  final TextStyle? defaultTextStyle;
  final EdgeInsetsGeometry? padding;
  final Map<String, Style>? customStyle;
  final void Function(String?)? onLinkTap;

  const HtmlContentWidget({
    super.key,
    required this.htmlData,
    this.defaultTextStyle,
    this.padding,
    this.customStyle,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: padding,
      child: Html(
        data: htmlData,
        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(defaultTextStyle?.fontSize ?? 14),
            color: defaultTextStyle?.color ?? theme.colorScheme.onSurface,
            fontFamily: defaultTextStyle?.fontFamily,
          ),
          "p": Style(
            margin: Margins.only(bottom: 8),
            fontSize: FontSize(14),
            lineHeight: LineHeight.number(1.5),
          ),
          "h1": Style(
            fontSize: FontSize(24),
            fontWeight: FontWeight.bold,
            margin: Margins.only(bottom: 12, top: 8),
            color: theme.colorScheme.onSurface,
          ),
          "h2": Style(
            fontSize: FontSize(20),
            fontWeight: FontWeight.bold,
            margin: Margins.only(bottom: 10, top: 8),
            color: theme.colorScheme.onSurface,
          ),
          "h3": Style(
            fontSize: FontSize(18),
            fontWeight: FontWeight.w600,
            margin: Margins.only(bottom: 8, top: 6),
            color: theme.colorScheme.onSurface,
          ),
          "h4": Style(
            fontSize: FontSize(16),
            fontWeight: FontWeight.w600,
            margin: Margins.only(bottom: 6, top: 4),
            color: theme.colorScheme.onSurface,
          ),
          "strong": Style(
            fontWeight: FontWeight.bold,
          ),
          "b": Style(
            fontWeight: FontWeight.bold,
          ),
          "em": Style(
            fontStyle: FontStyle.italic,
          ),
          "i": Style(
            fontStyle: FontStyle.italic,
          ),
          "u": Style(
            textDecoration: TextDecoration.underline,
          ),
          "ul": Style(
            margin: Margins.only(bottom: 8, left: 16),
          ),
          "ol": Style(
            margin: Margins.only(bottom: 8, left: 16),
          ),
          "li": Style(
            margin: Margins.only(bottom: 4),
            fontSize: FontSize(14),
            lineHeight: LineHeight.number(1.4),
          ),
          "a": Style(
            color: theme.colorScheme.primary,
            textDecoration: TextDecoration.underline,
          ),
          "blockquote": Style(
            margin: Margins.only(left: 16, bottom: 8),
            padding: HtmlPaddings.only(left: 12),
            border: Border(
              left: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 3,
              ),
            ),
            backgroundColor: theme.colorScheme.surface,
          ),
          "code": Style(
            backgroundColor: theme.colorScheme.surfaceVariant,
            padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
            fontFamily: 'monospace',
            fontSize: FontSize(13),
          ),
          "pre": Style(
            backgroundColor: theme.colorScheme.surfaceVariant,
            padding: HtmlPaddings.all(12),
            margin: Margins.only(bottom: 8),
            whiteSpace: WhiteSpace.pre,
          ),
          "table": Style(
            border: Border.all(color: theme.dividerColor),
            margin: Margins.only(bottom: 8),
          ),
          "th": Style(
            backgroundColor: theme.colorScheme.surfaceVariant,
            padding: HtmlPaddings.all(8),
            border: Border.all(color: theme.dividerColor),
            fontWeight: FontWeight.bold,
          ),
          "td": Style(
            padding: HtmlPaddings.all(8),
            border: Border.all(color: theme.dividerColor),
          ),
          // Merge custom styles if provided
          ...?customStyle,
        },
        // onLinkTap: onLinkTap ?? (url, _, __) {
        //   // Default link handling - you can customize this
        //   debugPrint('Link tapped: $url');
        // },
      ),
    );
  }
}

// Convenience constructors for common use cases
class ProductDescriptionHtml extends HtmlContentWidget {
  const ProductDescriptionHtml({
    super.key,
    required super.htmlData,
    super.padding = const EdgeInsets.all(16),
  }) : super(
    defaultTextStyle: const TextStyle(fontSize: 14, height: 1.5),
  );
}

class ArticleContentHtml extends HtmlContentWidget {
  const ArticleContentHtml({
    super.key,
    required super.htmlData,
    super.padding = const EdgeInsets.symmetric(horizontal: 16),
  }) : super(
    defaultTextStyle: const TextStyle(fontSize: 16, height: 1.6),
  );
}

class CompactHtml extends HtmlContentWidget {
  const CompactHtml({
    super.key,
    required super.htmlData,
    super.padding = const EdgeInsets.all(8),
  }) : super(
    defaultTextStyle: const TextStyle(fontSize: 12, height: 1.4),
  );
}
