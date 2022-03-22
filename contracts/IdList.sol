// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

struct RecordMeta {
    uint pos;
    bool exists;
}

struct GList {
    uint[] data;
    mapping (uint => RecordMeta) meta;
    uint count;
}


library IdContainers {
    
    function length(GList storage list) public view returns(uint) {
        return list.data.length;
    }

    function add(GList storage list, uint item) public returns(uint){
        RecordMeta memory record = list.meta[item];
        require(record.exists == false);
        list.count += 1;
        if (list.data.length == 0 || list.data[record.pos] != item) {
            list.data.push(item);
            list.meta[item] = RecordMeta(list.data.length - 1, true);
            return list.data.length - 1;
        } else {
            list.meta[item] = RecordMeta(record.pos, true);
            return record.pos;
        }
    }
    
    function pop(GList storage list) public returns(uint item){
        require(length(list) > 0);
        item = list.data[length(list)-1];
        RecordMeta memory record = list.meta[item];
        require(record.exists);
        list.data.pop();
        list.meta[item] = RecordMeta(0, false); // Like it never existed
        list.count -= 1;
    }
    
    // Remove at index
    function removeAt(GList storage list, uint index) public returns(uint item){
        require(index < length(list));
        if (index == length(list) - 1) {
            item = pop(list);
        } else { 
            item = list.data[index];
            RecordMeta memory record = list.meta[item];
            require(record.exists);
            list.meta[item] = RecordMeta(record.pos, false); // We know it was at index "pos" at some point
            list.count -= 1;
        } 
    }

    // Remove value
    function remove(GList storage list, uint item) public returns(bool, uint){
        RecordMeta memory record = list.meta[item];
        if (!record.exists)
            return (false, record.pos);
        if (record.pos == length(list) - 1) {
            pop(list);
        } else {
            list.meta[item] = RecordMeta(record.pos, false);
            list.count -= 1;
        }
        return (true, record.pos);
    }

    function getRecord(GList storage list, uint index) public view returns(uint, bool) {
        require(index < list.data.length);
        uint item = list.data[index];
        RecordMeta memory record = list.meta[item];
        return (item, record.exists);
    }
    
    function get(GList storage list, uint index) public view returns(uint) {
        bool exists;
        uint item;
        (item, exists) = getRecord(list, index);
        require(exists);
        return item;
    }

    function getIndex(GList storage list, uint item) public view returns(uint) {
        RecordMeta memory record = list.meta[item];
        require(record.exists);
        return record.pos;
    }
}