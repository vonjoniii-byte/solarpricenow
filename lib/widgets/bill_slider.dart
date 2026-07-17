// BillSlider — 2-month electricity bill input.
// Restyled to the imported design: a large numeral display + a custom track
// slider. Real engine range preserved: $100–$1,500, $10 step.

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class BillSlider extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onSubmitted;

  const BillSlider({
    super.key,
    this.initialValue = 250.0,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  State<BillSlider> createState() => _BillSliderState();
}

class _BillSliderState extends State<BillSlider> {
  static const double _min = 100.0;
  static const double _max = 1500.0;
  static const double _step = 10.0;

  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue.clamp(_min, _max);
  }

  String _format(double v) {
    final int n = v.round();
    final String s = n.toString();
    final StringBuffer buf = StringBuffer('\$');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    if (v >= _max) buf.write('+');
    return buf.toString();
  }

  void _onChanged(double newValue) {
    final double stepped = (newValue / _step).round() * _step;
    if (stepped == _value) return;
    setState(() => _value = stepped);
    widget.onChanged(stepped);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Big numeral display (scales down on very narrow screens)
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _format(_value),
                style: AppTypography.metricValue.copyWith(
                  fontSize: 46,
                  letterSpacing: -1.6,
                  height: 0.9,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(
                  '/ 2 months',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Slider (track/fill/thumb from sliderTheme)
        Semantics(
          label: 'Average electricity bill, ${_value.round()} dollars',
          value: _format(_value),
          slider: true,
          child: SizedBox(
            height: 44,
            child: Slider(
              value: _value,
              min: _min,
              max: _max,
              onChanged: _onChanged,
              onChangeEnd: widget.onSubmitted,
            ),
          ),
        ),
        // Range labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_format(_min),
                  style: AppTypography.caption
                      .copyWith(fontWeight: FontWeight.w600)),
              Text(_format(_max),
                  style: AppTypography.caption
                      .copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "Roughly what you pay across a two-month bill. We use this to estimate "
          "your home's usage.",
          style: AppTypography.caption.copyWith(height: 1.5),
        ),
      ],
    );
  }
}
