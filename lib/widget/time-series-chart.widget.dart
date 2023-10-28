/// Timeseries chart example

// class SimpleTimeSeriesChart extends StatelessWidget {
// const SimpleTimeSeriesChart(
//   this.seriesList, {
//   Key? key,
//   required this.animate,
//   this.onChange,
//   this.initialDateSelection,
// }) : super(key: key);
//
// // final List<charts.Series<dynamic, DateTime>> seriesList;
// final bool animate;
// // final void Function(charts.SelectionModel<DateTime> model)? onChange;
// final Tuple2<String, DateTime>? initialDateSelection;
//
// @override
// Widget build(BuildContext context) {
// return charts.TimeSeriesChart(
//   seriesList,
//   animate: animate,
//   dateTimeFactory: const charts.LocalDateTimeFactory(),
//   behaviors: [
//     charts.InitialSelection(selectedDataConfig: [
//       if (initialDateSelection != null)
//         charts.SeriesDatumConfig(initialDateSelection!.item1, initialDateSelection!.item2)
//     ])
//   ],
//   selectionModels: [
//     charts.SelectionModelConfig(
//       type: charts.SelectionModelType.info,
//       changedListener: (model) => onChange != null ? onChange!(model) : null,
//     )
//   ],
// );
//   }
// }
//
// /// Sample time series data type.
// class TimeSeries<T> {
//   final DateTime time;
//   final int total;
//   final T object;
//
//   TimeSeries(this.time, this.total, this.object);
// }
