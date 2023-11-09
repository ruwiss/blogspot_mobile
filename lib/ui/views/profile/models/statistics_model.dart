class StatisticsModel {
  StatisticsModel(this.days7, this.days30, this.all);
  final String days7;
  final String days30;
  final String all;

  StatisticsModel.fromJson(Map<String, String> json)
      : days7 = json['7days'] as String,
        days30 = json['30days'] as String,
        all = json['all'] as String;
}
