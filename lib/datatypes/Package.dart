

import 'package:hermes_tracker/datatypes/Student.dart';

class Package {
  Student owner;
  String name;
  String location;
  String rDate;
  String dDate;
  String dProof;
  String carrier;
  String notes;
  String tracking;

  Package(Student owner, String location, String carrier, String rDate, String tracking,
      String notes) {
    this.owner = owner;
    this.name = owner.getName();
    this.location = location;
    this.rDate = rDate;
    this.carrier = carrier;
    this.notes = notes;
    this.tracking = tracking;
  }
  void setOwner(Student owner){
    this.owner = owner;
    this.name = owner.getName();
  }
  Student getOwner(){
    return owner;
  }
  String getName() {
    return this.owner.getName();
  }
  void setLocation(String location){
    this.location = location;
  }
  String getLocation(){
    return location;
  }
  void setRDate(String rDate){
    this.rDate = rDate;
  }
  String getRDate(){
    return rDate;
  }
  void setCarrier(String carrier){
    this.carrier = carrier;
  }
  String getCarrier(){
    return carrier;
  }
  void setNotes(String notes){
    this.notes = notes;
  }
  String getNotes(){
    return notes;
  }
  void setTracking(String tracking){
    this.tracking = tracking;
  }
  String getTracking(){
    return tracking;
  }
  void setDDate(String dDate){
    this.dDate = dDate;
  }
  String getDDate(){
    return dDate;
  }
  void setDProof(String dProof){
    this.dProof = dProof;
  }
  String getDProof(){
    return dProof;
  }
}