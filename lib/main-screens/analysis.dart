// Bar chart example
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class VisualAndAnalysis extends StatefulWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  VisualAndAnalysis(this.seriesList, {this.animate});

  factory VisualAndAnalysis.withSampleData() {
    return new VisualAndAnalysis(
      [],
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  _VisualAndAnalysisState createState() => _VisualAndAnalysisState();

 
}

class _VisualAndAnalysisState extends State<VisualAndAnalysis> {
  void initState()
  {
    print(widget.seriesList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new charts.BarChart(
        widget.seriesList,
        animate: widget.animate,
        barGroupingType: charts.BarGroupingType.grouped,
      ),
    );
  }
}
