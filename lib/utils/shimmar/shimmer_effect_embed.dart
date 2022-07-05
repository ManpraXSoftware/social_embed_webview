import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class ShimmerEffectEmbed extends StatelessWidget {
  double? height ;
  var ar ;
  ShimmerEffectEmbed({Key? key,this.height,this.ar}) : super(key: key);

  Color shimmerBaseColor =  Colors.grey[300]!;
  Color shimmerHighlightColor =  Colors.grey[100]!;

  @override
  Widget build(BuildContext context) {
    return _shimmerCard();
  }

  Widget _shimmerCard() {
    return ar!=null ? AspectRatio(
      aspectRatio: ar,
      child: bodyUI()
    ):Container(
      height: height,
      width: double.infinity,
      // margin: EdgeInsets.only(left: 25, right: 25, top: 0, bottom: 20),
      child:  bodyUI(),
    );
  }

  Widget bodyUI(){
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      child: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerHighlightColor,
        enabled: true,
        child: Container(
          width: double.infinity,
          height: height,
          color: Colors.black,
        ),
      ),
    );
  }
}
