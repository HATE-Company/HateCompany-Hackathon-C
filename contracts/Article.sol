// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";

// the Dapp contract that will handle the main operations of the dapp like holiding user data and storing of entries
contract blogContract {

    // using the openzeppelin counter contract
    using Counters for Counters.Counter; // OpenZepplin Counter
    Counters.Counter private _ids;
    // Mapping of an address to a user profile
    // the user profile will be stored on IPFS and the hash used in the mapping
    mapping (address => string) profile;

    // Mapping of an address to an array posts/entries
    // can be use to retrieve a users posts/entries
    mapping (address => Post[]) userPosts;

    // Mapping of all postcounts/ids to post
    // to store all posts
    mapping (uint => Post) AllPosts;

    // Mapping of an address to the number of entries a user has made
    mapping (address => uint) postsCount;

    // Mapping of users to their stages
    mapping (address => uint) userCategory; // 1 for bronze, 2 for silver, 3 for gold

    // struct of a post/entry
    struct Post {
        address author; // the writter of the post
        string topic; // the topic being written on
        string category; // the level of the maker of the post, bronze, silver or gold
        string postHash; // the hash of the object stored on IPFS
        string commentsHash; // the hash of comment objects stored on IPFS
    }

    // array of the avaible topics that can be written about
    // topics can be added by those are gold tier
    string[] topics;

    // Address of the owner of the contract
    // will have some authority/right to perform certain actions
    // like approval for minting NFTs
    address public owner;

    // The thresholds for different levels
    // when reached users can mint different NFTs
    uint public silverLimit; // the number of posts needed to get to silver rank
    uint public goldLimit; // the number of posts needed to get to gold rank

    constructor(uint _silverLimit, uint _goldLimit) {
        owner = msg.sender;
        silverLimit = _silverLimit;
        goldLimit = _goldLimit;
    }

    // function to sign a user up
    function signUp(string memory profileHash) public {
        profile[msg.sender] = profileHash; // the profile object has to be stored on IPFS already and the hash returned
        userCategory[msg.sender] = 1; // 1 to denote bronze
    }

    // function to make an entry/post
    function postEntry(string memory entryHash, string memory topic) public {

        _ids.increment();
        string memory category = getCategory(msg.sender); // the user's category
        Post memory p;
        p.author = msg.sender;
        p.commentsHash = " "; // the hash of the comments object to be stored on IPFS, set as an empty string as default
        p.topic = topic; // the topic of the entry
        p.postHash = entryHash; // the entry contents object has to be stored on IPFS already and the hash returned
        p.category = category;
        uint id = _ids.current();

        userPosts[msg.sender].push(p);
        AllPosts[id] = p;
        postsCount[msg.sender] = postsCount[msg.sender] + 1;
    }

    // function to return a user category
    function getCategory(address user) view public returns (string memory category) {
        if (userCategory[user] == 1) {
            category = "bronze";
        } else if(userCategory[user] == 2) {
            category = "silver";
        }
        else {
            category = "gold";
        }
    }

    // function to create new topic, can only be done by a gold user
    function createTopic(string memory topic) public {
        require(userCategory[msg.sender] == 3, "You have to be gold user to user to add topics");
        topics.push(topic);
    }

    // function to return all topics
    function getTopics() view public returns (string[] memory) {
        return topics;
    }
}