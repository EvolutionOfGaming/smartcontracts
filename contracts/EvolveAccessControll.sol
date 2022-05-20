/* SPDX-License-Identifier: MIT OR Apache-2.0 */
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract EvolveAccessControll is Context, Ownable{
    using SafeMath for uint256;
    using Address for address;

    address public adminUpdater;
    address private admin;
    uint256 public adminLifeTime;
    uint256 public adminUpdateTime;
    constructor(address _adminUpdater){
        admin = _msgSender();
        adminUpdater= _adminUpdater;
        // default life time is 1 week
        adminLifeTime = 3600 * 24 * 7; 
        adminUpdateTime = block.timestamp;
    }

    modifier checkAdminExpireDate {
        uint256 _timestamp = block.timestamp;
        uint256 _expireTime = adminUpdateTime.add(adminLifeTime);
        if(_timestamp >= _expireTime){
            admin = address(0);
        }
        _;
    }

    modifier onlyAdmin {
        require(admin == _msgSender(), "Only sub admin can call this method.");
        _;
    }

    modifier ownerOrAdmin {
        require(_msgSender() == admin || _msgSender() == owner(), "To call this method you have to be owner or subAdmin!");
         _;
    }

    modifier isAdminUpdator{
        require(adminUpdater == _msgSender() || _msgSender() == owner() , "only admin updator can call this method");
        _;
    }

    function currentAdmin() external  view returns(address result){
        uint256 _timestamp = block.timestamp;
        uint256 _expireTime = adminUpdateTime.add(adminLifeTime);
        if(_timestamp >= _expireTime){
            result = address(0);
        }else{
            result = admin;
        }
    }

    function adminExpireDate() external view returns(uint256 _expierDate){
        _expierDate = adminUpdateTime.add(adminLifeTime);
    }

    function chnageAdminLifeTime(uint256 _newLifeTime) external  onlyOwner returns(bool){
        require(_newLifeTime != 0, "Life time can't be zero!");
        adminLifeTime = _newLifeTime;
        return true;
    }

    function updateAdmin(address _newAdmin) internal  isAdminUpdator returns(bool){
        require(admin != _newAdmin, "New admin can't be same as current admin");
        admin = _newAdmin;
        uint256 _timestamp = block.timestamp;
        adminUpdateTime = _timestamp;
        return true;
    }

    function updateAdminUpdater(address _newAdminUpdater) external  onlyOwner returns (bool){
        adminUpdater = _newAdminUpdater;
        return true;
    }
}