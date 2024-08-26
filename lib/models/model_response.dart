class ModelResponse {
  ModelResponse({
    required this.response,
  });
  String response = "";
  
  ModelResponse.fromJson(Map<String, dynamic> json){
    response = json['response'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['response'] = response;
    return _data;
  }
}