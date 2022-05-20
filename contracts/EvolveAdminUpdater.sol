/* SPDX-License-Identifier: MIT OR Apache-2.0 */
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./IEvolveFactory.sol";

contract EvolveAdminUpdater is Context, Ownable {
    using Address for address;
    address admin;
    IEvolveFactory public factory;
    
    constructor(IEvolveFactory _factoryAddress ){
        admin = _msgSender();
        factory = _factoryAddress;
    }

    modifier adminOrOwner{
        require(_msgSender() == owner() || _msgSender() == admin, "method can call just with owner or admin!");
        _;
    }

    function updateFactory(IEvolveFactory _newFactoryAddress) external onlyOwner returns(bool){
        factory = _newFactoryAddress;
        return true;
    }

    function updateFactoryAdmin(address payable _newAdmin) external payable adminOrOwner returns(bool){
        require(_newAdmin != address(0), "addmin address can't be null");
        require(msg.value != 0, "you ca't transfer admin witout any value.");
        factory.updateFactoryAdmin(_newAdmin);

        admin = _newAdmin;
        _newAdmin.transfer(msg.value);

        return true;
    }

}