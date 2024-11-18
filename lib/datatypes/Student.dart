class Student {
  String studentID;
  String name;
  String polyEmail;

  Student (String studentID, String name, String polyEmail) {
    this.studentID = studentID;
    this.name = name;
    this.polyEmail = polyEmail;
  }
  void setStudentID(String studentID){
    this.studentID = studentID;
  }
  String getStudentID(){
    return studentID;
  }
  void setName(String name){
    this.name = name;
  }
  String getName(){
    return name;
  }
  void setPolyEmail(String polyEmail){
    this.polyEmail = polyEmail;
  }
  String getPolyEmail(){
    return polyEmail;
  }
}
