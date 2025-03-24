import 'package:flutter/material.dart';

import '/core/extensions/build_content_extensions.dart';
import '/core/extensions/num_extensions.dart';
import '/core/widgets/space.dart';
import '/features/entities/sub_category_entity.dart';

class RowSubcategoriesButton extends StatelessWidget {
  const RowSubcategoriesButton({
    super.key,
    required this.subcategories,
    required this.selectedSubcateroryId,
    required this.onButtonPress,
  });

  final List<SubcategoryEntity> subcategories;
  final Function(SubcategoryEntity) onButtonPress;
  final String? selectedSubcateroryId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          subcategories.map((sub) {
            return Padding(
              padding: eiAll1,
              child: ElevatedButton(
                onPressed: () => onButtonPress(sub),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedSubcateroryId == sub.id
                          ? Colors.blue
                          : context.colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(borderRadius: 8.borderRadius),
                ),
                child: Text(
                  sub.name,
                  style: TextStyle(color: selectedSubcateroryId == sub.id ? Colors.white : null),
                ),
              ),
            );
          }).toList(),
    );
  }
}
