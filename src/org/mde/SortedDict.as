/*
Copyright 2009, Matthew Eernisse (mde@fleegix.org)

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/
package util {
  public class SortedDict {
    public var count:int;
    protected var items:Object;
    protected var order:Array;
    protected var defaultValue:*;

    public function SortedDict(...args):void {
      this.count = 0;
      this.items = {}; // Hash keys and their values
      this.order = []; // Array for sort order
      if (args.length) {
        this.defaultValue = args[0];
      }
    }

    /**
    * Adds an item to the SortedDict at the end of the current sort order.
    *
    * @param key The key to use for the new item.
    * @param value The value to use for the new item.
    *
    * @see SortedDict#setItem()
    * @see SortedDict#getItem()
    * @see SortedDict#removeItem()
    */
    public function addItem(key:String, val:*):void {
      return setByKey(key, val);
    }

    /**
    * Retrieves an item from the SortedDict using either its key, or its
    * index in the sort.
    *
    * @param keyOrIndex Either the string key or numeric index for the
    * item to retrieve.
    *
    * @return An item in the SortedDict.
    *
    * @see SortedDict#setItem()
    * @see SortedDict#addItem()
    * @see SortedDict#removeItem()
    *
    * @example The following retrieves an item with the key 'geddyLee':
    * <listing version="3.0">
    * var player:Object = someSortedDict.getItem('geddyLee');
    * </listing>
    * This example retrieves the item at index of 2 in the sort:
    * <listing version="3.0">
    * var player:Object = someSortedDict.getItem(2);
    * </listing>
    */
    public function getItem(keyOrIndex:*):* {
      if (keyOrIndex is String) {
        return getByKey(keyOrIndex);
      }
      else if (keyOrIndex is Number) {
        return getByIndex(keyOrIndex);
      }
    }

    /**
    * Sets the value of an item in the SortedDict either by its key, or
    * at a specific index in the sort. When setting by key, if an item
    * with that key does not already exist, this method adds a new item
    * with that key at the end of the current sort.
    *
    * @param keyOrIndex Either the string key or numeric index for the
    * desired item.
    * @param val The value for the item to set in the SortedDict.
    *
    * @see SortedDict#getItem()
    * @see SortedDict#addItem()
    * @see SortedDict#removeItem()
    *
    * @example The following sets an item with the key 'alexLifeson':
    * <listing version="3.0">
    * var alex:Object = {instrument: 'guitar'};
    * someSortedDict.setItem('alexLifeson', alex);
    * </listing>
    * This example sets the value of the item at index of 2 in the sort:
    * <listing version="3.0">
    * var alex:Object = {instrument: 'guitar'};
    * someSortedDict.setItem(2, alex);
    * </listing>
    */
    public function setItem(keyOrIndex:*, val:*):void {
      if (keyOrIndex is String) {
        setByKey(keyOrIndex, val);
      }
      else if (keyOrIndex is Number) {
        setByIndex(keyOrIndex, val);
      }
    }

    /**
    * Removes an item from the SortedDict using either its key, or its
    * index in the sort.
    *
    * @param keyOrIndex Either the string key or numeric index for the
    * item to remove.
    *
    * @see SortedDict#getItem()
    * @see SortedDict#setItem()
    * @see SortedDict#addItem()
    *
    * @example The following removes an item with the key 'neilPeart':
    * <listing version="3.0">
    * someSortedDict.removeItem('neilPeart');
    * </listing>
    * This example removes the item at index of 2 in the sort:
    * <listing version="3.0">
    * someSortedDict.removeItem(2);
    * </listing>
    */
    public function removeItem(keyOrIndex:*):void {
      if (keyOrIndex is String) {
        removeByKey(keyOrIndex);
      }
      else if (keyOrIndex is Number) {
        removeByIndex(keyOrIndex);
      }
    }

    /**
    * Checks for the existence of an item with the given key in the
    * SortedDict.
    *
    * @param key The key to look for.
    *
    * @return true or false, depending on if the given key exists.
    */
    public function hasKey(key:String):Boolean {
      return (key in items);
    };

    /**
    * Checks for the existence of an item with the given value in the
    * SortedDict. Note that this check uses the triple-equal (===)
    * to check for equality.
    *
    * @param val The item value to look for.
    *
    * @return true or false, depending on if the given value exists.
    */
    public function hasValue(val:*):Boolean {
      for (var i:int = 0; i < order.length; i++) {
        if (items[order[i]] === val) {
          return true;
        }
      }
      return false;
    }

    /**
    * Returns a delimited list of all the keys in the SortedDict.
    *
    * @param delimiter The desired character to use for the separator
    * in the delimited list of keys.
    * @default ,
    *
    * @return A delimited list of all the keys in the SortedDict.
    */
    public function allKeys(delimiter:String = ','):String {
      return order.join(delimiter);
    }

    /**
    * Replace the key of an item in the SortedDict with a different key.
    * The position of the item in the order remains unchanged.
    *
    * @param oldKey The key to be replaced.
    * @param newKey The key to replace the old key with.
    *
    */
    public function replaceKey(oldKey:String, newKey:String):void {
      // If item for newKey exists, nuke it
      if (hasKey(newKey)) {
        removeItem(newKey);
      }
      items[newKey] = items[oldKey];
      delete items[oldKey];
      for (var i:int = 0; i < order.length; i++) {
        if (order[i] == oldKey) {
          order[i] = newKey;
        }
      }
    }

    /**
    * Inserts a new item in the SortedDict at the specified index in the sort.
    * Items at that index and higher will keep their current sort order, but
    * will be shifted over to accommodate the new item.
    *
    * @param index The index at which to insert the new item.
    * @param key The key to use for the new item.
    * @param val The value of the new item.
    *
    */
    public function insertAtIndex(index:int, key:String, val:*):void {
      order.splice(index, 0, key);
      items[key] = val;
      count++;
    }

    /**
    * Inserts a new item in the SortedDict after the item with the
    * specified key in the sort.
    *
    * @param refKey The key for the item after which to insert the new item.
    * @param key The key to use for the new item.
    * @param val The value of the new item.
    *
    */
    public function insertAfterKey(refKey:String, key:String, val:*):void {
      var pos:int = getIndex(refKey);
      insertAtIndex(pos, key, val);
    }

    /**
    * Gets the index in the sort for the item with the specified key.
    *
    * @param key The key for the desired item.
    *
    * @return The index for the specified item in the sort.
    */
    public function getIndex(key:String):int {
      return order.indexOf(key);
    }

    /**
    * Iterates over each item in the SortedDict, in order, calling a
    * function on the key and value of each item.
    *
    * @param func The function to call on each item. This function should
    * take two arguments, the key and value for each item.
    * @param context An optional execution context to use when calling
    * the function.
    *
    * @see SortedDict#eachKey()
    * @see SortedDict#eachValue()
    *
    * @example The following iterates over the items in a SortedDict, printing
    * out the key and value.
    * <listing version="3.0">
    * // Create a SortedDict
    * var dict:SortedDict = new SortedDict();
    *  
    * // Add some stuff to it
    * dict.addItem('geddy', 'Bass guitar');
    * dict.addItem('alex', 'Guitar');
    * dict.addItem('neil', 'Drums');
    *  
    * // Print out each key and value
    * dict.each(function (key:String, val:String):void {
    *   trace(key + ': ' + val);
    * });
    * </listing>
    */
    public function each(func:Function, context:Object = null):void {
      for (var i:int = 0; i < order.length; i++) {
        var key:String = order[i];
        var val:* = items[key];
        func.call(context, key, val);
      }
    }

    /**
    * Iterates over each item in the SortedDict, in order, calling a
    * function on the key for each item.
    *
    * @see SortedDict#each()
    * @see SortedDict#eachValue()
    *
    * @param func The function to call on each item. This function should
    * take one argument, the key for each item.
    * @param context An optional execution context to use when calling
    * the function.
    */
    public function eachKey(func:Function, context:Object = null):void {
      for (var i:int = 0; i < order.length; i++) {
        var key:String = order[i];
        func.call(context, key);
      }
    };

    /**
    * Iterates over each item in the SortedDict, in order, calling a
    * function on the value for each item.
    *
    * @see SortedDict#each()
    * @see SortedDict#eachKey()
    *
    * @param func The function to call on each item. This function should
    * take one argument, the value for each item.
    * @param context An optional execution context to use when calling
    * the function.
    */
    public function eachValue(func:Function, context:Object = null):void {
      for (var i:int = 0; i < order.length; i++) {
        var key:String = order[i];
        var val:* = items[key];
        func.call(context, val);
      }
    };

    /*
    // FIXME: This doesn't handle the case of the same key in
    // both SortedDicts
    public function concat(newDict:SortedDict):void {
      for (var i:int = 0; i < newDict.order.length; i++) {
        var key:String = newDict.order[i];
        var val:* = newDict.items[key];
        setItem(key, val);
      }
    }
    */

    /**
    * Adds a new item to the SortedDict at the end of the current sort.
    *
    * @see SortedDict#pop()
    * @see SortedDict#unshift()
    * @see SortedDict#shift()
    *
    * @param key The key for the new item.
    * @param value The value for the new item.
    *
    * @return The new count of items in the SortedDict after adding
    * the item.
    */
    public function push(key:String, val:*):int {
      insertAtIndex(count, key, val);
      return count;
    }

    /**
    * Removes the item from the SortedDict at the end of the current
    * sort and returns it.
    *
    * @see SortedDict#push()
    * @see SortedDict#unshift()
    * @see SortedDict#shift()
    *
    * @return The item at the end of the current sort in the SortedDict.
    */
    public function pop():* {
      if (count == 0) {
        return null;
      }
      else {
        var pos:int = count - 1;
        var ret:* = items[order[pos]];
        removeByIndex(pos);
        return ret;
      }
    }

    /**
    * Adds a new item to the SortedDict at the begnning of the current sort.
    *
    * @see SortedDict#push()
    * @see SortedDict#pop()
    * @see SortedDict#shift()
    *
    * @param key The key for the new item.
    * @param value The value for the new item.
    *
    * @return The new count of items in the SortedDict after adding
    * the item.
    */
    public function unshift(key:String, val:*):int {
      insertAtIndex(0, key, val);
      return count;
    }

    /**
    * Removes the item from the SortedDict at the beginning of the current
    * sort and returns it.
    *
    * @see SortedDict#push()
    * @see SortedDict#pop()
    * @see SortedDict#unshift()
    *
    * @return The item at the beginning of the current sort in the SortedDict.
    */
    public function shift(key:String, val:*):* {
      if (count == 0) {
        return null;
      }
      else {
        var pos:int = 0;
        var ret:* = items[order[pos]];
        removeByIndex(pos);
        return ret;
      }
    }

    /**
    * Changes the content of the SortedDict, adding new elements while
    * removing old elements.
    *
    * @param index Index at which to start changing the array.
    * If negative, will begin that many elements from the end.
    * @param numToRemove An integer indicating the number of old
    * array elements to remove. If howMany is 0, no elements are removed.
    * @param dict an optional SortedDict to splice into the sort order
    * at the specified index.
    */
    public function splice(index:int, numToRemove:int, dict:SortedDict = null):void {
      var i:int;
      // Removal
      if (numToRemove > 0) {
        // Items
        var limit:int = index + numToRemove;
        for (i = index; i < limit; i++) {
          delete items[order[i]];
        }
        // Order
        order.splice(index, numToRemove);
      }
      // Adding
      if (dict) {
        // Items
        for (i= 0; i < dict.order.length; i++) {
          var key:String = dict.order[i];
          var val:* = dict.items[key];
          // No duplicate keys, dude
          if (hasKey(key)) {
            throw new Error('Cannot slice SortedDict -- duplicate key "' + key + '"');
          }
          setItem(key, val);
        }
        // Order
        var newOrder:Array = dict.order;
        // Want to call splice(index, 0, [newOrderElemA], [newOrderElemB] ...)
        // Use apply -- this means sticking index and 0 on the front of the args
        newOrder.unshift(0);
        newOrder.unshift(index);
        order.splice.apply(order, newOrder);
      }
      count = order.length;
    };

    /**
    * Sorts the SortedDict.
    *
    * @see SortedDict#reverse()
    *
    * @param comparator An optional comparator function to use to determine
    * the sorting order of the element in the SortedDict. This function should
    * take two arguments to compare. Given the elements A and B, the result
    * should be one of the following three values:
    * <ul><li>-1, if A should appear before B in the sorted sequence</li>
    * <li>0, if A equals B</li><li>1, if A should appear after B in the sorted
    * sequence</li></ul>
    *
    * @example The following example sorts first on the 'foo' property of
    * items in the SortedDict, then on the 'bar' property.
    * <listing version="3.0">
    * // Create the SortedDict
    * var d:SortedDict = new SortedDict();
    *  
    * // Add some items with a 'foo' and 'bar' property
    * d.addItem('itemA', {
    *   foo: 'a',
    *   bar: 'c'
    * });
    * d.addItem('itemB', {
    *   foo: 'b',
    *   bar: 'b'
    * });
    * d.addItem('itemC', {
    *   foo: 'c',
    *   bar: 'a'
    * });
    *  
    * // Comparator for sorting on 'foo'
    * var compFoo:Function = function (a:Object, b:Object):int {
    *   return a.foo > b.foo ? 1 : -1;
    * };
    * d.sort(compFoo);
    *  
    * // Iterate over the list in order and trace 'foo' property
    * // Trace output will be:
    * // itemA, foo: a
    * // itemB, foo: b
    * // itemC, foo: c
    * d.each(function (key:String, val:Object):void {
    *   trace(key + ', foo: ' + val.foo);
    * });
    * </listing>
    */
    public function sort(comparator:Function = null):void {
      var defaultSort:Function = function (a:*, b:*):int {
        return (a.toLowerCase() >=
          b.toLowerCase()) ? 1 : -1;
      };
      var c:Function = comparator || defaultSort;
      var arr:Array = [];
      var i:int;
      if (!(c is Function)) {
        throw('SortedDict.sort requires a valid comparator function.');
      }
      var comp:Function = function (a:Object, b:Object):int {
        return c(a.val, b.val);
      };
      for (i = 0; i < order.length; i++) {
        var key:String = order[i];
        arr[i] = { key: key, val: items[key] };
      }
      arr.sort(comp);
      order = [];
      for (i = 0; i < arr.length; i++) {
        order.push(arr[i].key);
      }
    }

    /**
    * Reverses the sort order of the SortedDict
    *
    * @see SortedDict#sort()
    *
    */
    public function reverse():void {
      order.reverse();
    }

    /* Private functions for get/set/remove by key */
    private function getByKey(key:String):* {
      return items[key];
    }

    private function setByKey(key:String, val:*):void {
      var v:* = null;
      if (arguments.length == 1) {
        v = defaultValue;
      }
      else { v = val; }
      if (!(key in items)) {
        order[count] = key;
        count++;
      }
      items[key] = v;
    }

    private function removeByKey(key:String):void {
      if (!(key in items)) {
        var pos:int;
        delete items[key]; // Remove the value
        // Find the key in the order list
        for (var i:int = 0; i < order.length; i++) {
          if (order[i] == key) {
            pos = i;
          }
        }
        order.splice(pos, 1); // Remove the key
        count--; // Decrement the length
      }
    }

    /* Private functions for get/set/remove by index */
    private function getByIndex(ind:int):* {
      return items[order[ind]];
    }

    private function setByIndex(ind:int, val:*):void {
      if (ind < 0 || ind >= count) {
        throw new Error('Index out of bounds. SortedDict length is ' + count);
      }
      items[order[ind]] = val;
    }

    private function removeByIndex(ind:int):void {
      if (ind < 0 || ind >= count) {
        throw new Error('Index out of bounds. SortedDict length is ' + count);
      }
      delete items[order[ind]]
      order.splice(ind, 1);
      count--;
    }

  }
}


