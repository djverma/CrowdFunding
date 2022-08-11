pragma solidity >=0.5.0 <0.9.0;
contract CrowdFunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public  minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoter;
        mapping(address=>bool) voters;
    }
    mapping(uint=>Request) public requests;
    uint public noOfRequests;
    constructor(uint _target,uint _deadline){
        target=_target;
        deadline=block.timestamp+_deadline;
        minimumContribution=100 wei;
        manager=msg.sender;
    }
    function sendEth() public payable{
        require(block.timestamp<deadline,"Deadline has passed");
        require(msg.value>=minimumContribution,"Minimum contribution not met");
        if(contributors[msg.sender]==0){
            noOfContributors++;
            raisedAmount=raisedAmount+msg.value;
            contributors[msg.sender]+=msg.value;
        }
    }
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
    function refund() public{
        require(block.timestamp>deadline && raisedAmount>target,"Not eligible");
        require(contributors[msg.sender]>0,"No net contributions");
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
    modifier onlyManager(){
        require(msg.sender==manager,"Only manager can call this");
        _;
    }
    function createRequest(string memory _description,address payable _recipient,uint _value) public onlyManager{
        Request storage newRequest=requests[noOfRequests];
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noOfVoter=0;
        noOfRequests++;
    }
    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0,"You must be a contributor to vote");
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have Already voted");
        thisRequest.noOfVoter++;
        thisRequest.voters[msg.sender]=true;
    }
    function makePayment(uint _requestNo) public onlyManager{
        require(raisedAmount>=target);
        Request storage thisRequest=requests[_requestNo];
        require(!(requests[_requestNo].completed),"payment has already been made");
        require(thisRequest.noOfVoter>noOfContributors/2,"Not enough Votes");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;
    }


}
