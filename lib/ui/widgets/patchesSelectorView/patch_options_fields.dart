import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:revanced_manager/models/patch.dart';
import 'package:revanced_manager/ui/widgets/shared/custom_card.dart';

class BooleanPatchOption extends StatelessWidget {
  const BooleanPatchOption({
    super.key,
    required this.patchOption,
    required this.removeOption,
    required this.onChanged,
  });

  final Option patchOption;
  final void Function(Option option) removeOption;
  final void Function(dynamic value, Option option) onChanged;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier patchOptionValue = ValueNotifier(patchOption.value);
    return PatchOption(
      widget: Align(
        alignment: Alignment.bottomLeft,
        child: ValueListenableBuilder(
          valueListenable: patchOptionValue,
          builder: (context, value, child) {
            return Switch(
              value: value ?? false,
              onChanged: (bool value) {
                patchOptionValue.value = value;
                onChanged(value, patchOption);
              },
            );
          },
        ),
      ),
      patchOption: patchOption,
      removeOption: (Option option) {
        removeOption(option);
      },
    );
  }
}

class IntAndStringPatchOption extends StatelessWidget {
  const IntAndStringPatchOption({
    super.key,
    required this.patchOption,
    required this.removeOption,
    required this.onChanged,
  });

  final Option patchOption;
  final void Function(Option option) removeOption;
  final void Function(dynamic value, Option option) onChanged;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier patchOptionValue = ValueNotifier(patchOption.value);
    String getKey() {
      if (patchOption.value != null && patchOption.values != null) {
        final List values = patchOption.values!.entries
            .where((e) => e.value == patchOption.value)
            .toList();
        if (values.isNotEmpty) {
          return values.first.key;
        }
      }
      return '';
    }

    return PatchOption(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFieldForPatchOption(
            value: patchOption.value,
            values: patchOption.values,
            optionType: patchOption.valueType,
            selectedKey: getKey(),
            onChanged: (value) {
              patchOptionValue.value = value;
              onChanged(value, patchOption);
            },
          ),
          ValueListenableBuilder(
            valueListenable: patchOptionValue,
            builder: (context, value, child) {
              if (patchOption.required && value == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    I18nText(
                      'patchOptionsView.requiredOption',
                      child: Text(
                        '',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
      patchOption: patchOption,
      removeOption: (Option option) {
        removeOption(option);
      },
    );
  }
}

class IntStringLongListPatchOption extends StatelessWidget {
  const IntStringLongListPatchOption({
    super.key,
    required this.patchOption,
    required this.removeOption,
    required this.onChanged,
  });

  final Option patchOption;
  final void Function(Option option) removeOption;
  final void Function(dynamic value, Option option) onChanged;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> values = List.from(patchOption.value ?? []);
    final ValueNotifier patchOptionValue = ValueNotifier(values);
    final String type = patchOption.valueType;

    String getKey(dynamic value) {
      if (value != null && patchOption.values != null) {
        final List values = patchOption.values!.entries
            .where((e) => e.value.toString() == value)
            .toList();
        if (values.isNotEmpty) {
          return values.first.key;
        }
      }
      return '';
    }

    bool isCustomValue() {
      if (values.length == 1 && patchOption.values != null) {
        if (getKey(values[0]) != '') {
          return false;
        }
      }
      return true;
    }

    bool isTextFieldVisible = isCustomValue();

    return PatchOption(
      widget: ValueListenableBuilder(
        valueListenable: patchOptionValue,
        builder: (context, value, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: value.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  final e = values[index];
                  return TextFieldForPatchOption(
                    value: e.toString(),
                    values: patchOption.values,
                    optionType: type,
                    selectedKey: value.length > 1 ? '' : getKey(e),
                    showDropdown: index == 0,
                    onChanged: (newValue) {
                      if (newValue is List) {
                        values.clear();
                        isTextFieldVisible = false;
                        values.add(newValue.toString());
                      } else {
                        isTextFieldVisible = true;
                        if (values.length == 1 &&
                            values[0].toString().startsWith('[') &&
                            type.contains('Array')) {
                          values.clear();
                          values.addAll(patchOption.value);
                        } else {
                          values[index] = type == 'StringArray'
                              ? newValue
                              : type == 'IntArray'
                                  ? int.parse(
                                      newValue.toString().isEmpty
                                          ? '0'
                                          : newValue.toString(),
                                    )
                                  : num.parse(
                                      newValue.toString().isEmpty
                                          ? '0'
                                          : newValue.toString(),
                                    );
                        }
                      }
                      patchOptionValue.value = List.from(values);
                      onChanged(values, patchOption);
                    },
                    removeValue: () {
                      patchOptionValue.value = List.from(patchOptionValue.value)
                        ..removeAt(index);
                      values.removeAt(index);
                      onChanged(values, patchOption);
                    },
                  );
                },
              ),
              if (isTextFieldVisible) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      if (type == 'StringArray') {
                        patchOptionValue.value =
                            List.from(patchOptionValue.value)..add('');
                        values.add('');
                      } else {
                        patchOptionValue.value =
                            List.from(patchOptionValue.value)..add(0);
                        values.add(0);
                      }
                      onChanged(values, patchOption);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, size: 20),
                        I18nText(
                          'add',
                          child: const Text(
                            '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      patchOption: patchOption,
      removeOption: (Option option) {
        removeOption(option);
      },
    );
  }
}

class UnsupportedPatchOption extends StatelessWidget {
  const UnsupportedPatchOption({super.key, required this.patchOption});

  final Option patchOption;

  @override
  Widget build(BuildContext context) {
    return PatchOption(
      widget: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: I18nText(
            'patchOptionsView.unsupportedOption',
            child: const Text(
              '',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      patchOption: patchOption,
      removeOption: (_) {},
    );
  }
}

class PatchOption extends StatelessWidget {
  const PatchOption({
    super.key,
    required this.widget,
    required this.patchOption,
    required this.removeOption,
  });

  final Widget widget;
  final Option patchOption;
  final void Function(Option option) removeOption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patchOption.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              patchOption.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!patchOption.required)
                        IconButton(
                          onPressed: () => removeOption(patchOption),
                          icon: const Icon(Icons.delete),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  widget,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextFieldForPatchOption extends StatefulWidget {
  const TextFieldForPatchOption({
    super.key,
    required this.value,
    required this.values,
    this.removeValue,
    required this.onChanged,
    required this.optionType,
    required this.selectedKey,
    this.showDropdown = true,
  });

  final String? value;
  final Map<String, dynamic>? values;
  final String optionType;
  final String selectedKey;
  final bool showDropdown;
  final void Function()? removeValue;
  final void Function(dynamic value) onChanged;

  @override
  State<TextFieldForPatchOption> createState() =>
      _TextFieldForPatchOptionState();
}

class _TextFieldForPatchOptionState extends State<TextFieldForPatchOption> {
  final TextEditingController controller = TextEditingController();
  String? selectedKey;
  String? defaultValue;

  @override
  Widget build(BuildContext context) {
    final bool isStringOption = widget.optionType.contains('String');
    final bool isArrayOption = widget.optionType.contains('Array');
    selectedKey ??= widget.selectedKey;
    controller.text = !isStringOption &&
            isArrayOption &&
            selectedKey == '' &&
            (widget.value != null && widget.value.toString().startsWith('['))
        ? ''
        : widget.value ?? '';
    defaultValue ??= controller.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showDropdown && (widget.values?.isNotEmpty ?? false))
          DropdownButton<String>(
            style: const TextStyle(
              fontSize: 16,
            ),
            borderRadius: BorderRadius.circular(4),
            dropdownColor: Theme.of(context).colorScheme.secondaryContainer,
            isExpanded: true,
            value: selectedKey,
            items: widget.values!.entries
                .map(
                  (e) => DropdownMenuItem(
                    value: e.key,
                    child: RichText(
                      text: TextSpan(
                        text: e.key,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: ' ${e.value}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList()
              ..add(
                DropdownMenuItem(
                  value: '',
                  child: I18nText(
                    'patchOptionsView.customValue',
                    child: const Text(
                      '',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            onChanged: (value) {
              if (value == '') {
                controller.text = defaultValue!;
                widget.onChanged(controller.text);
              } else {
                controller.text = widget.values![value].toString();
                widget.onChanged(
                  isArrayOption ? widget.values![value] : controller.text,
                );
              }
              setState(() {
                selectedKey = value;
              });
            },
          ),
        if (selectedKey == '')
          TextFormField(
            inputFormatters: [
              if (widget.optionType.contains('Int'))
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              if (widget.optionType.contains('Long'))
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]*')),
            ],
            controller: controller,
            keyboardType:
                isStringOption ? TextInputType.text : TextInputType.number,
            decoration: InputDecoration(
              suffixIcon: PopupMenuButton(
                tooltip: FlutterI18n.translate(
                  context,
                  'patchOptionsView.tooltip',
                ),
                itemBuilder: (BuildContext context) {
                  return [
                    if (isArrayOption)
                      PopupMenuItem(
                        value: 'remove',
                        child: I18nText('remove'),
                      ),
                    if (isStringOption) ...[
                      PopupMenuItem(
                        value: 'patchOptionsView.selectFilePath',
                        child: I18nText('patchOptionsView.selectFilePath'),
                      ),
                      PopupMenuItem(
                        value: 'patchOptionsView.selectFolder',
                        child: I18nText('patchOptionsView.selectFolder'),
                      ),
                    ],
                  ];
                },
                onSelected: (String selection) async {
                  switch (selection) {
                    case 'patchOptionsView.selectFilePath':
                      final String? result = await FlutterFileDialog.pickFile();
                      if (result != null) {
                        controller.text = result;
                        widget.onChanged(controller.text);
                      }
                      break;
                    case 'patchOptionsView.selectFolder':
                      final DirectoryLocation? result =
                          await FlutterFileDialog.pickDirectory();
                      if (result != null) {
                        controller.text = result.toString();
                        widget.onChanged(controller.text);
                      }
                      break;
                    case 'remove':
                      widget.removeValue!();
                      break;
                  }
                },
              ),
              hintStyle: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            onChanged: (String value) {
              widget.onChanged(value);
            },
          ),
      ],
    );
  }
}
