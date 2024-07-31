/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import '../../../pdf.dart';
import '../flex.dart';
import '../geometry.dart';
import '../page.dart';
import '../widget.dart';
import 'chart.dart';
import 'grid_cartesian.dart';
import 'point_chart.dart';
import 'package:intl/intl.dart';

class BarDataSet<T extends PointChartValue> extends PointDataSet<T> {
  BarDataSet({
    required List<T> data,
    String? legend,
    PdfColor? borderColor,
    double borderWidth = 1.5,
    PdfColor color = PdfColors.blue,
    bool? drawBorder,
    this.drawSurface = true,
    this.drawLabel = false,
    this.drawLabelFontSize = 8,
    this.drawLabelPrefixText = '',
    this.drawLabelSpaceLeft = 0,
    this.negativeValue = false,
    this.greatherValue = 0,
    this.lessValue = 100,
    this.surfaceOpacity = 1,
    this.width = 10,
    this.offset = 0,
    this.axis = Axis.horizontal,
    PdfColor? pointColor,
    double pointSize = 3,
    bool drawPoints = false,
    BuildCallback? shape,
    Widget Function(Context context, T value)? buildValue,
    ValuePosition valuePosition = ValuePosition.auto,
  })  : drawBorder = drawBorder ?? borderColor != null && color != borderColor,
        assert((drawBorder ?? borderColor != null && color != borderColor) ||
            drawSurface),
        super(
        legend: legend,
        color: pointColor ?? color,
        data: data,
        buildValue: buildValue,
        drawPoints: drawPoints,
        pointSize: pointSize,
        shape: shape,
        valuePosition: valuePosition,
        borderColor: borderColor,
        borderWidth: borderWidth,
      );

  final bool drawBorder;

  final bool drawSurface;

  final double surfaceOpacity;

  final double width;
  final double offset;

  final Axis axis;

  final bool drawLabel;
  final double drawLabelFontSize;
  final String drawLabelPrefixText;
  final double drawLabelSpaceLeft;

  final bool negativeValue;
  final double greatherValue;
  final double lessValue;

  void _drawSurface(Context context, ChartGrid grid, T value) {
    switch (axis) {
      case Axis.horizontal:
        if ( !negativeValue ) {
          // Rotina padrão
          final y = (grid is CartesianGrid) ? grid.xAxisOffset : 0.0;
          final p = grid.toChart(value.point);
          final x = p.x + offset - width / 2;
          final height = p.y - y;
          context.canvas.drawRect(x, y, width, height);

          // print('draw');
          // print('y $y');
          // print('p $p');
          // print('x $x');
          // print('p.x ${p.x}');
          // print('p.y ${p.y}');
          // print('value.x ${value.x}');
          // print('value.y ${value.y}');
          // print('height $height');
          // print('width $width');
          // print('offset $offset');
        } else {
          // implementação provisória para tratar gráficos com valores negativos
          // Feito apenas para Axis.horizontal
          final y = (grid is CartesianGrid) ? grid.xAxisOffset : 0.0;
          final p = grid.toChart(value.point);
          final x = p.x + offset - width / 2;
          final heightReal = p.y - y;
          final startY = (y * (( 0.48 * 10 * 2 ) * 2)) - y ;
          final height = (value.y < 0) ? startY - heightReal : heightReal - startY + y;
          if(value.y < 0){
            context.canvas.drawRect(x, startY - height, width, height);
          } else if (value.y > 0){
            context.canvas.drawRect(x, startY, width, height);
          }
          // print('draw negative');
          // print('y $y');
          // print('p $p');
          // print('x $x');
          // print('p.x ${p.x}');
          // print('p.y ${p.y}');
          // print('value.x ${value.x}');
          // print('value.y ${value.y}');
          // print('height $height');
          // print('width $width');
          // print('offset $offset');
        }
        // if ( value.y < 0) {
        //   final height = p.y;
        //   context.canvas.drawRect(x, y , width, height);
        // } else {
        //   final height = p.y - y;
        //   context.canvas.drawRect(x, y + 50, width, height);
        // }

        break;
      case Axis.vertical:
        final x = (grid is CartesianGrid) ? grid.yAxisOffset : 0.0;
        final p = grid.toChart(value.point);
        final y = p.y + offset - width / 2;
        final height = p.x - x;

        context.canvas.drawRect(x, y , height, width);
        break;
    }
  }

  void _drawLabel(Context context, ChartGrid grid, T value) {
    switch (axis) {
      case Axis.horizontal:
        if( value.y != 0) {
          final NumberFormat numberFormat = NumberFormat("#,##0.00", "pt-BR");
          // https://github.com/DavBfr/dart_pdf/issues/975
          // https://github.com/DavBfr/dart_pdf/issues/1269

          final y = (grid is CartesianGrid) ? grid.xAxisOffset : 0.0;
          final p = grid.toChart(value.point);
          final x =
          (p.x == double.infinity || p.x.isNaN ? 0.0 + offset + width : p.x + offset - width / 2);
          final height = p.y - y;
          final yPosition = (value.y > 0 ? y + height + 5.0 : y + height - 15.0 );


          context.canvas
            ..saveContext()
            ..setFillColor(PdfColors.black)
            ..drawString(
              context.canvas.defaultFont!,
              drawLabelFontSize,
              '${drawLabelPrefixText}${numberFormat.format(value.y)}',
              x + drawLabelSpaceLeft,
              yPosition,
              // y + height + 5.0,
            )
            ..setFillColor(color)
            ..restoreContext();
        }


        break;
      case Axis.vertical:
      // TODO:
        break;
    }
  }


  @override
  void layout(Context context, BoxConstraints constraints,
      {bool parentUsesSize = false}) {
    box = PdfRect.fromPoints(PdfPoint.zero, constraints.biggest);
  }

  @override
  void paint(Context context) {
    super.paint(context);

    if (data.isEmpty) {
      return;
    }

    final grid = Chart.of(context).grid;

    if (drawSurface) {
      for (final value in data) {
        _drawSurface(context, grid, value);
      }

      if (surfaceOpacity != 1) {
        context.canvas
          ..saveContext()
          ..setGraphicState(
            PdfGraphicState(opacity: surfaceOpacity),
          );
      }

      context.canvas
        ..setFillColor(color)
        ..fillPath();

      if (surfaceOpacity != 1) {
        context.canvas.restoreContext();
      }
    }

    if (drawLabel) {
      for (final value in data) {
        _drawLabel(context, grid, value);
      }
    }

    if (drawBorder) {
      for (final value in data) {
        _drawSurface(context, grid, value);
      }

      context.canvas
        ..setStrokeColor(borderColor ?? color)
        ..setLineWidth(borderWidth)
        ..strokePath();
    }
  }

  @override
  ValuePosition automaticValuePosition(
      PdfPoint point,
      PdfPoint size,
      PdfPoint? previous,
      PdfPoint? next,
      ) {
    final pos = super.automaticValuePosition(point, size, previous, next);
    if (pos == ValuePosition.right || pos == ValuePosition.left) {
      return ValuePosition.top;
    }

    return pos;
  }
}
