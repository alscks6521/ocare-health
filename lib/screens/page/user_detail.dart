import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../widgets/user_box_user_detail.dart';
import '../../calendarAndChart/providers/health_data_provider.dart';
import '../../calendarAndChart/widgets/chart_widhget.dart';
import '../../calendarAndChart/models/HealthData.dart';


class UserDetail extends StatefulWidget {
  const UserDetail({super.key});

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {


  final TextEditingController _guardianController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _bloodSugarController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    final healthDataList = Provider.of<HealthDataProvider>(context).allData;

    var title = "${user.guardian}님 건강 정보";
    double size = 35;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          // Column 대신 ListView 사용
          padding: const EdgeInsets.all(25.0),

          children: [
            SizedBox(height: 25,),


            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: size,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 55.0),


            UserBoxUserDetail(
              guardianController: _guardianController,
              systolicController: _systolicController,
              diastolicController: _diastolicController,
              bloodSugarController: _bloodSugarController,
            ),

            const SizedBox(height: 16.0),
            const SizedBox(height: 32,),
            _buildChartText(),
            const SizedBox(height: 24,),
            // const SizedBox(height: 80.0), // 바텀 패딩 추가

            Container(
              height: MediaQuery.of(context).size.height * 0.8, // 화면 높이의 80%로 설정

              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: healthDataList.isNotEmpty
                          ? ListView(
                        children: [
                          SizedBox(
                            height: 250,
                            child: buildBloodPressureChart(healthDataList, context),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Align(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      color: Colors.green,
                                    ),
                                    const Text('안전 수축기'),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      color: Colors.blue,
                                    ),
                                    const Text('수축기'),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      color: Colors.red,
                                    ),
                                    const Text('안전 이완기'),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      color: Colors.orange,
                                    ),
                                    const Text('이완기'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          SizedBox(
                            height: 250,
                            child: buildBloodSugarChart(healthDataList, context),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Align(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      color: Colors.green,
                                    ),
                                    const Text('안전 혈당'),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      color: Colors.purple,
                                    ),
                                    const Text('혈당'),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                          : const Center(child: Text('혹시 데이터를 추가하셨나요?')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildChartText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '최근 건강 통계',
            style: TextStyle(
              fontSize: 35.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBloodPressureChart(List<HealthData> healthDataList, BuildContext context) {
    return ChartHelper.buildChart(
      healthDataList: healthDataList,
      context: context,
      lineColors: [Colors.blue, Colors.orange], // 수축기와 이완기 혈압에 대한 색상
      normalValues: [200, 120, 80], // 수축기와 이완기 혈압의 정상값
      valueExtractors: [
            (HealthData data) => data.systolicBP.toDouble(),
            (HealthData data) => data.diastolicBP.toDouble(),
      ],
    );
  }

  Widget buildBloodSugarChart(List<HealthData> healthDataList, BuildContext context) {
    return ChartHelper.buildChart(
      healthDataList: healthDataList,
      context: context,
      lineColors: [Colors.purple],
      normalValues: [300, 100],
      valueExtractors: [
            (HealthData data) => data.bloodSugar.toDouble(),
      ],
    );
  }

}
