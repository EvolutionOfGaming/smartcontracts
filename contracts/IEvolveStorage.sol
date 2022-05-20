/* SPDX-License-Identifier: MIT OR Apache-2.0 */
pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;
interface IEvolveStorage{
     struct Preset {
        uint256 matchPrice;
        uint256 numberOfTeamMemebr;
        uint256 date;
        uint256 createAt;
    }
    struct Competion {
        Preset preset;
        address[] teamA;
        address[] teamB;
        CompetionStatus status;
        CompetionWinner winners;
        uint256 priceRate;
        uint256 createAt;
    }
    enum CompetionStatus { PENDING, CANCELED, DONE }
    enum CompetionWinner {TEAMA , TEAMB , DRAW, OPEN}
    
    function addNewPreset(uint256 _matchPrice, uint256 _numberOfTeamMemebr , uint256 _createAt) external returns(uint);
    function updateCompetionWinner(uint _competionId, uint8 _winnerTeam) external returns(bool);
    function updateCompetionStatus(uint _competionId, uint8 _status) external returns(bool);
    function updateFactoryAddress(address _factory) external returns(bool);
    function addNewCompetion(uint256 _presetId, address[] calldata _teamA, address[] calldata _teamB, uint256 _priceRate, uint256 _createAt) external returns(uint256 competitionId);
    
    function getPreset(uint256 _presetId) external view returns(uint256,uint256);
    function getCompetion(uint256 _competionId) external view returns(uint256 presetPrice,uint256 playerCount,address[] memory _teamA, address[] memory _teamB, uint _competionStatus, uint _competionWinner, uint256 _priceRate);
}