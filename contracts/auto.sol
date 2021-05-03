
pragma solidity ^0.4.0;

contract SomeContract {

  function SomeContract() public payable{

  }

  event TheOemAddedAnItem(address oemaddress,string itemname,uint quantityofitem);
  event TheManufacturerRequestedForParts(string nameofpart,uint numberofparts);
  event TheManufacturerRequestedForMoreParts(string nameofthepart,uint numberoftheparts);
  event TheOemGotPaid(address _oemsaddress,uint moneyinthepoolforoem);
  event TheManufacturerRefundedTheReturnDamagedItemsItem(string ReturnDamagedItemsitem,uint numberofReturnDamagedItems);
  event TheVehicleIsReadyToBeSendToTheDealer(uint thevehicleid);

  struct auto_industry {

    uint typ;
    address add;

  }

  // add oem to the network
  mapping(address => auto_industry ) addautoindustry;

  function InsertOEM() {

    addautoindustry[msg.sender]=auto_industry(1,msg.sender);

  }

  modifier onlyOEM() {

    if (addautoindustry[msg.sender].typ==1){
      _;
    }

    else {
      throw;
    }

  }
  // add automobile manufacturer
  function AddAutoFactory() {

    addautoindustry[msg.sender]=auto_industry(2,msg.sender);

  }

  modifier OnlyAutoFactory() {

    if (addautoindustry[msg.sender].typ==2){
      _;
    }

    else {
      throw;
    }

  }

  mapping (string => uint) parts_mapping;
  mapping (string => uint) id_mapping;
  mapping (string => uint) time_mapping;
  mapping (string => bytes32) hashing_item;
  mapping (string => uint) price_mapping;

  //takes input of part name,no of part,part id (for adding the part to list)
  function InsertParts(string name, uint quantity, uint ids, uint price) onlyOEM {

    uint p = parts_mapping[name];
    parts_mapping[name]=p + quantity;
    uint time_now = now;
    id_mapping[name] = ids;
    time_mapping[name] = time_now;
    price_mapping[name] = price;
    hashing_item[name] = sha3(name,ids,time_now);
    TheOemAddedAnItem(msg.sender,name,quantity);

  }

  //ShowQuantitys the no of quantity remaining for a particular part
  function ShowQuantity(string part_name) constant returns(uint) {

    return parts_mapping[part_name];

  }

  //not useful just for testing
  function ShowTime(string part_name) constant returns(uint) {

    return time_mapping[part_name];

  }

  //modiier takes name and id of the part and tells weather it is genuine
  modifier ConfirmPart(string name, uint id_item) {

    uint  time_created=time_mapping[name];
    bytes32 hash_temp=sha3(name,id_item,time_created);
    bytes32 orig_hash=hashing_item[name];
    if(hash_temp==orig_hash) {
      _;
    }
    else {
      throw;
    }

  }

  uint pooltime;

  // used to calculate money for desired part from oem
  function AvailablePartAmount (string name_of_part , uint how_many) constant returns(uint) {

    uint amount = how_many * price_mapping[name_of_part];
    return amount;

  }

  // checking for authenticity of parts and paying temporarily to the pool
  function UsingOEMParts(string name_of_part, uint how_many, uint id_of_item) ConfirmPart(name_of_part , id_of_item) payable {

    if( parts_mapping[name_of_part] < how_many ){
      TheManufacturerRequestedForMoreParts(name_of_part,how_many);
    }

    parts_mapping[name_of_part] = parts_mapping[name_of_part] - how_many;
    uint amount = msg.value;
    this.transfer(amount);
    pooltime=now;

    TheManufacturerRequestedForParts(name_of_part,how_many);


  }

  //give the amount present in the pool
  function CalcPoolMoney() constant returns (uint){

    return this.balance;

  }

  //for giving back ReturnDamagedItems items,after this manufacturer gets his money and oem takes the ReturnDamagedItems part
  function ReturnDamagedItems(string _name_of_part, uint no_of_pieces) OnlyAutoFactory {

    uint __amount = no_of_pieces * price_mapping[_name_of_part];
    msg.sender.transfer(__amount);
    TheManufacturerRefundedTheReturnDamagedItemsItem(_name_of_part,no_of_pieces);

  }

  //by this function oem can take out money out of the pool to his account after 10 hrs
  function ReimburseToOEM() payable onlyOEM() {

    if(now-pooltime > 36000){
      TheOemGotPaid(msg.sender, this.balance);
      msg.sender.transfer(this.balance);
    }

  }
 mapping (uint => vehicle) partinauto;
 struct vehicle
 {
   uint vehicle_id;
   string vehicle_name;
 }
 mapping (uint => uint) completeness;
//for assigning the part to the vehicle
 function PartToAuto(uint partid,string vehicle_n,uint _vehicle_id) OnlyAutoFactory
 {
   if(completeness[_vehicle_id]==1)
   {
     throw;
   }
   else
   {
   partinauto[partid]=vehicle(_vehicle_id,vehicle_n);
   }
 }
//for finding the location(the vehicle) where the part is installed
 function CheckPartPlace(uint partid) constant returns(uint a,string b)
 {
   a=partinauto[partid].vehicle_id;
   b=partinauto[partid].vehicle_name;
 }
//to set the status of manufactiring complete and is ready to be sent to the dealer
 function AutoAssembled(uint vehicle_id_)
 {

   completeness[vehicle_id_]=1;
   TheVehicleIsReadyToBeSendToTheDealer(vehicle_id_);
 }
  function () payable{

  }

}
