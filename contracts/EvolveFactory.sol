/* SPDX-License-Identifier: MIT OR Apache-2.0 */
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./EvolveAccessControll.sol";
import "./IEvolveStorage.sol";
import "./IEvolveBulkSender.sol";
import "./IEvolveFactory.sol";
contract EvolveFactory is Context, Ownable, EvolveAccessControll, IEvolveFactory {

    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    IEvolveStorage public evolveStorage;
    IEvolveBulkSender public evolveBulkSender;
    IERC20 public tokenAddress;
    uint256 public tokenPriceByUSD = 1e18;
    address public giftTokenProvider;

    constructor(IEvolveStorage _storageAddress , IEvolveBulkSender _bulkSender,IERC20 _tokenAddress, address _adminUpdater) EvolveAccessControll(_adminUpdater){
        evolveStorage = _storageAddress;
        tokenAddress = _tokenAddress;
        _updateBulkSender(_bulkSender);
    }

    function updateGiftTokenProvider(address _newGiftProvider) external ownerOrAdmin returns(bool){
        require(_newGiftProvider != giftTokenProvider, "the new gift provider cannot be same as before!");
        giftTokenProvider = _newGiftProvider;
        return true;
    }

    function updateTokenRate(uint newRate) external onlyOwner returns(bool){
       tokenPriceByUSD = newRate;
       return true; 
    }

    function updateStorage(IEvolveStorage _storageAddress) external override onlyOwner returns(bool){
        evolveStorage = _storageAddress;
        return true;
    }

    function updateBulkSender(IEvolveBulkSender _bulkSender) external override onlyOwner returns(bool){
        _updateBulkSender(_bulkSender);
        return true;
    }

    function _updateBulkSender(IEvolveBulkSender _bulkSender) private returns(bool){
        evolveBulkSender = _bulkSender;
        approveToBulkSender();
        return true;
    }

    function updateTokenAddress(IERC20 _tokenAddress) external override onlyOwner returns(bool){
        tokenAddress = _tokenAddress;
        approveToBulkSender();
        return true;
    }

    function approveToBulkSender() private returns(bool){
        address to = address(evolveBulkSender);
        uint256 amount = 99999999999999999e18;

        tokenAddress.approve(to, amount);
        return true;
    }


    function updateFactoryAdmin(address _newAdminAddress) external override  isAdminUpdator returns(bool){
        super.updateAdmin(_newAdminAddress);
        return true;
    }

    function addNewCompetion(uint256 _presetId, address[] calldata _teamA, address[] calldata _teamB , bool[] calldata _boolNeedReplace, uint256 _createAt) external override ownerOrAdmin returns(uint256 competitionId){
        require(_teamA.length == _teamB.length , "member of team A need to be equal to member of team B!");
        require(_teamA.length + _teamB.length == _boolNeedReplace.length, "sum of length of teams must be equal to bool replace list!");
        (uint matchPrice,uint playerNumber) = evolveStorage.getPreset(_presetId);

        require(_teamA.length == playerNumber, "team member need to be equal with preset team number!");
        address[] memory allPlayerAddressList = concatenateArraysWithReplaceAddress(_teamA, _teamB, _boolNeedReplace, giftTokenProvider);
        
        uint256 competionPriceByToken = calculateMatchPrice(matchPrice, tokenPriceByUSD, 18);
        evolveBulkSender.bulkReceive(competionPriceByToken, allPlayerAddressList, address(tokenAddress));
        
        competitionId = evolveStorage.addNewCompetion(_presetId, _teamA, _teamB, tokenPriceByUSD, _createAt);
        return competitionId;
    }

    

    function setCompetionWinner(uint256 _competionId, uint8 _winnerTeam) external override  ownerOrAdmin returns(bool){

       (uint256 presetPrice,uint256 playerCount,address[] memory _teamA, address[] memory _teamB, uint _competionStatus, uint _competionWinner, uint _priceRate) = evolveStorage.getCompetion(_competionId);

       require(_competionStatus == 0, "this competion is not pending!");
       require(_competionWinner == 3, "this competion already have a winner!");

       evolveStorage.updateCompetionWinner(_competionId, _winnerTeam);
       evolveStorage.updateCompetionStatus(_competionId, 2);

       address[] memory _winnerTeamAddress;
       uint competionReward = presetPrice.mul(2);

       if(_winnerTeam == 0){
           _winnerTeamAddress = _teamA;
       }
       else if(_winnerTeam == 1){
           _winnerTeamAddress = _teamB;
       }
       else if(_winnerTeam == 2){
           competionReward = presetPrice;
           _winnerTeamAddress = concatenateArrays(_teamA, _teamB);
       }

       require(_winnerTeamAddress.length == playerCount || _winnerTeamAddress.length / 2  == playerCount  , "_winnerTeamAddress.length == playerCount || _winnerTeamAddress.length == playerCount.div(2)");
       uint competionPriceByToken = calculateMatchPrice(competionReward, _priceRate, 18);
       evolveBulkSender.bulkWithdraw(competionPriceByToken, _winnerTeamAddress, address(tokenAddress));

       return true;
    }

    function cancelCompetion(uint256 _competionId) external override ownerOrAdmin returns(bool){

        (uint256 presetPrice,uint256 playerCount,address[] memory _teamA, address[] memory _teamB, uint _competionStatus, uint _competionWinner, uint256 _priceRate ) = evolveStorage.getCompetion(_competionId);

        require(_competionStatus == 0, "this competion is not pending!");
        require(_competionWinner == 4, "this competion already have a winner!");

        evolveStorage.updateCompetionWinner(_competionId, 2);
        evolveStorage.updateCompetionStatus(_competionId, 1);
        
        address[] memory _winnerTeamAddress = concatenateArrays(_teamA, _teamB);

        require(_winnerTeamAddress.length == playerCount);
        uint competionPriceByToken = calculateMatchPrice(presetPrice, _priceRate, 18);
        
        evolveBulkSender.bulkWithdraw( competionPriceByToken, _winnerTeamAddress, address(tokenAddress));
        return true;
    }

    function destroyFactory(address _newFactory) external override onlyOwner returns(bool){
        uint tokenBalnce = tokenAddress.balanceOf(address(this));
        tokenAddress.transfer(_newFactory, tokenBalnce);
        return true;
    }
    

    function concatenateArrays(address[] memory _Accounts, address[] memory _Accounts2) private pure returns(address[] memory) {
        address[] memory returnArr = new address[](_Accounts.length + _Accounts2.length);

        uint i=0;
        for (; i < _Accounts.length; i++) {
            returnArr[i] = _Accounts[i];
        }

        uint j=0;
        while (j < _Accounts2.length) {
            returnArr[i++] = _Accounts2[j++];
        }

        return returnArr;
    } 

    function concatenateArraysWithReplaceAddress(address[] memory _Accounts, address[] memory _Accounts2 , bool[] memory _replaceAddressList, address _replaceAddress) private returns(address[] memory) {
        address[] memory returnArr = concatenateArrays(_Accounts,_Accounts2 );
        uint k = 0;
        for(;k < returnArr.length; k++){
            bool _needReplace =  _replaceAddressList[k];
            if(_needReplace == true){
                returnArr[k] = _replaceAddress;
            }
        }
        return returnArr;
    }

    function calculateMatchPrice(uint _competionPrice, uint _priceRate, uint precision) private pure returns(uint){
        return _competionPrice*(10**precision)/_priceRate;
    }

}