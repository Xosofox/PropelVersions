<?php

// Template for creating base node class on tree table.
//
// $Id: Node.tpl,v 1.8 2005/04/04 11:02:40 dlawson_mi Exp $


require_once 'propel/engine/builder/om/ClassTools.php';

$db = $table->getDatabase();
if($table->getPackage()) {
    $package = $table->getPackage();
} else {
    $package = $targetPackage;
}

$CLASS = $table->getPhpName() . 'NodePeer';
echo '<' . '?' . 'php';

?>


require_once '<?php echo ClassTools::getFilePath($package, $table->getPhpName() . 'NodePeer') ?>';

/**
 * Base tree node class for manipulating a tree of <?php echo $table->getPhpName() ?> objects.
 * This class will wrap these objects within a "node" interface. It provides a
 * method overload mechanism which allows you to use a <?php echo $table->getPhpName() ?>Node
 * object just like a <?php $table->getPhpName() ?> object.
 * 
 * To avoid tree corruption, you should always use this class to make changes to
 * the tree and objects within it rather than using the <?php echo $table->getPhpName() ?> 
 * class directly.
 *
<?php if ($addTimeStamp) { ?>
 * This class was autogenerated by Propel on:
 *
 * [<?php echo $now ?>]
 *
<?php } ?>
 * @package <?php echo $package ?> 
 *
 */
class <?php echo $basePrefix . $table->getPhpName() ?>Node /*implements IteratorAggregate*/
{
    /**
     * @var <?php echo $table->getPhpName() ?> Object wrapped by this node.
     */
    var $obj = null;
    
    /**
     * The parent node for this node.
     * @var <?php echo $table->getPhpName() ?>Node
     */
    var $parentNode = null;

    /**
     * Array of child nodes for this node. Nodes indexes are one-based.
     * @var array
     */
    var $childNodes = array();

    /**
     * Constructor.
     *
     * @param <?php echo $table->getPhpName() ?> Object wrapped by this node.
     */
    function <?php echo $table->getPhpName() ?>Node($obj = null)
    {
        Propel::assertParam($obj, '<?php echo $CLASS; ?>', '<?php echo $table->getPhpName() ?>Node', 1);
        $obj =& Param::get($obj);
        
        if ($obj !== null)
        {
            $this->obj =& $obj;
        }
        else
        {
            $setNodePath = "set" . <?php echo $table->getPhpName() ?>NodePeer::NPATH_PHPNAME();
            $this->obj =& new <?php echo $table->getPhpName() ?>();
            $this->obj->$setNodePath('0');
        }
    }

    /**
     * Convenience overload for wrapped object methods.
     *
     * @param string Method name to call on wrapped object.
     * @param mixed Parameter accepted by wrapped object set method.
     * @return mixed Return value of wrapped object method.
     * @throws PropelException Fails if method is not defined for wrapped object.
     */
    function & callObjMethod($name, $parms = null)
    {
		$params =& Param::get($parms);
        if (method_exists($this->obj, $name)) {
			if (is_array($params)) {
				$implode = array();
				$keys = array_keys($params);
				foreach($keys as $key)
					$implode [] = "\$params['{$key}']";
				eval('$result =& $this->obj->$name(' . implode(',', $implode) . ');');
			}
			else {
				$result =& $this->obj->$name($params);
			}
			return $result;
		}
        else
            return new PropelException(PROPEL_ERROR, "get method not defined: $name");
    }

    /**
     * Sets the default options for iterators created from this object.
     * The options are specified in map format. The following options 
     * are supported by all iterators. Some iterators may support other
     * options:
     *
     *   "querydb" - True if nodes should be retrieved from database.
     *   "con" - Connection to use if retrieving from database.
     *
     * @param string Type of iterator to use ("pre", "post", "level").
     * @param array Map of option name => value.
     * @return void
     * @todo Implement other iterator types (i.e. post-order, level, etc.)
     */ 
    function setIteratorOptions($type, $opts)
    {
        $this->itType = $type;
        $this->itOpts = $opts;
    }
    
    /**
     * Returns a pre-order iterator for this node and its children.
     *
     * @param string Type of iterator to use ("pre", "post", "level")
     * @param array Map of option name => value.
     * @return NodeIterator
     */
    function & getIterator($type = null, $opts = null)
    {
        if ($type === null)
            $type = (isset($this->itType) ? $this->itType : 'Pre');

        if ($opts === null)
            $opts = (isset($this->itOpts) ? $this->itOpts : array());
            
        $itclass = ucfirst(strtolower($type)) . 'OrderNodeIterator';
        
        require_once('propel/om/' . $itclass . '.php');
        return new $itclass($this, $opts);
    }
        
    /**
     * Returns the object wrapped by this class.
     * @return <?php echo $table->getPhpName() . "\n" ?>
     */
    function & getNodeObj()
    {
        return $this->obj;
    }
        
    /**
     * Convenience method for retrieving nodepath.
     * @return string
     */
    function getNodePath()
    {
        $getNodePath = 'get' . <?php echo $table->getPhpName() ?>NodePeer::NPATH_PHPNAME();
        return $this->obj->$getNodePath();
    }

    /**
     * Returns one-based node index among siblings.
     * @return int
     */
    function getNodeIndex()
    {
        $npath = $this->getNodePath();
		//strrpos fix
		$sep = 0;
        while(false !== ($last = strpos($npath, <?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP(), $sep))) {
			$sep = $last + strlen(<?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP());
		}
        return (int) ($sep != 0 ? substr($npath, $sep) : $npath);
    }
    
    /**
     * Returns one-based node level within tree (root node is level 1).
     * @return int
     */
    function getNodeLevel()
    {
        return (substr_count($this->getNodePath(), <?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP()) + 1);
    }
    
    /** 
     * Returns true if specified node is a child of this node. If recurse is
     * true, checks if specified node is a descendant of this node.
     *
     * @param <?php echo $table->getPhpName() ?>Node Node to look for.
     * @param boolean True if strict comparison should be used.
     * @param boolean True if all descendants should be checked.
     * @return boolean
     */
    function hasChildNode(&$node, $strict = false, $recurse = false)
    {
        foreach ($this->childNodes as $key => $childNode)
        {
            if ($this->childNodes[$key]->equals($node, $strict))
                return true;
                
            if ($recurse && $this->childNodes[$key]->hasChildNode($node, $recurse))
                return true;
        }
        
        return false;
    }

    /**
     * Returns child node at one-based index. Retrieves from database if not 
     * loaded yet.
     *
     * @param int One-based child node index.
     * @param boolean True if child should be retrieved from database.
     * @param Connection Connection to use if retrieving from database.
     * @return <?php echo $table->getPhpName() ?>Node
     */
    function & getChildNodeAt($i, $querydb = false, $con = null)
    {
		Propel::assertParam($con, '<?php echo $CLASS; ?>', 'getChildNodeAt', 3);
    	$con =& Param::get($con);
    	
        if ($querydb && 
            !$this->obj->isNew() && 
            !$this->obj->isDeleted() && 
            !isset($this->childNodes[$i]))
        {
            $criteria =& new Criteria(<?php echo $table->getPhpName() ?>Peer::DATABASE_NAME());
            $criteria->add(<?php echo $table->getPhpName() ?>NodePeer::NPATH_COLNAME(),
				$this->getNodePath() . <?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP() . $i,
				Criteria::EQUAL());

            if ($childObj =& <?php echo $table->getPhpName() ?>Peer::doSelectOne($criteria, Param::set($con)))
                $this->attachChildNode(new <?php echo $table->getPhpName() ?>Node(Param::set($childObj)));
        }

        return (isset($this->childNodes[$i]) ? $this->childNodes[$i] : null);
    }

    /**
     * Returns first child node (if any). Retrieves from database if not loaded yet.
     *
     * @param boolean True if child should be retrieved from database.
     * @param Connection Connection to use if retrieving from database.
     * @return <?php echo $table->getPhpName() ?>Node
     */
    function & getFirstChildNode($querydb = false, $con = null)
    {
		Propel::assertParam($con, '<?php echo $CLASS; ?>', 'getFirstChildNode', 2);
    	$con =& Param::get($con);
        return $this->getChildNodeAt(1, $querydb, Param::set($con));
    }
        
    /**
     * Returns last child node (if any). 
     *
     * @param boolean True if child should be retrieved from database.
     * @param Connection Connection to use if retrieving from database.
     */
    function & getLastChildNode($querydb = false, $con = null)
    {
		Propel::assertParam($con, '<?php echo $CLASS; ?>', 'getLastChildNode', 2);
		$con =& Param::get($con);
        $lastNode = null;

        if ($this->obj->isNew() || $this->obj->isDeleted())
        {
			if (count($this->childNodes)) {
				end($this->childNodes);
                $lastNode =& $this->childNodes[key($this->childNodes)];
			}
        }
        else if ($querydb)
        {
            $criteria =& new Criteria(<?php echo $table->getPhpName() ?>Peer::DATABASE_NAME());
            $criteria->add(<?php echo $table->getPhpName() ?>NodePeer::NPATH_COLNAME(), $this->getNodePath() . <?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP() . '%', Criteria::LIKE());
            $criteria->addAnd(<?php echo $table->getPhpName() ?>NodePeer::NPATH_COLNAME(), $this->getNodePath() . <?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP() . '%' . <?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP() . '%', Criteria::NOT_LIKE());
            $criteria->addDescendingOrderByColumn(<?php echo $table->getPhpName() ?>NodePeer::NPATH_COLNAME());

            $lastObj =& <?php echo $table->getPhpName() ?>Peer::doSelectOne($criteria, Param::set($con));

            if ($lastObj !== null)
            {
                $lastNode =& new <?php echo $table->getPhpName() ?>Node(Param::set($lastObj));
				$endNode = null;

				if (count($this->childNodes)) {
					end($this->childNodes);
                	$endNode =& $this->childNodes[key($this->childNodes)];
				}
                
                if ($endNode)
                {
                    if ($endNode->getNodePath() > $lastNode->getNodePath())
                        return new PropelException(PROPEL_ERROR, 'Cached child node inconsistent with database.');
                    else if ($endNode->getNodePath() == $lastNode->getNodePath())
                        $lastNode =& $endNode;
                    else
                        $this->attachChildNode($lastNode);
                }
                else
                {
                    $this->attachChildNode($lastNode);
                }
            }
        }

        return $lastNode;
    }

    /**
     * Returns next (or previous) sibling node or null. Retrieves from database if 
     * not loaded yet.
     *
     * @param boolean True if previous sibling should be returned.
     * @param boolean True if sibling should be retrieved from database.
     * @param Connection Connection to use if retrieving from database.
     * @return <?php echo $table->getPhpName() ?>Node
     */
    function & getSiblingNode($prev = false, $querydb = false, $con = null)
    {
		Propel::assertParam($con, '<?php echo $CLASS; ?>', 'getSiblingNode', 3);
    	$con =& Param::get($con);
        $nidx = $this->getNodeIndex();
        
        if ($this->isRootNode())
        {
            return null;
        }
        else if ($prev)
        {
            if ($nidx > 1 && ($parentNode =& $this->getParentNode($querydb, Param::set($con))))
                return $parentNode->getChildNodeAt($nidx-1, $querydb, Param::set($con));
            else
                return null;
        }
        else
        {
            if ($parentNode =& $this->getParentNode($querydb, Param::set($con)))
                return $parentNode->getChildNodeAt($nidx+1, $querydb, Param::set($con));
            else
                return null;
        }
    }

    /**
     * Returns parent node. Loads from database if not cached yet.
     *
     * @param boolean True if parent should be retrieved from database.
     * @param Connection Connection to use if retrieving from database.
     * @return <?php echo $table->getPhpName() ?>Node
     */
    function & getParentNode($querydb = true, $con = null)
    {
		Propel::assertParam($con, '<?php echo $CLASS; ?>', 'getParentNode', 2);
    	$con =& Param::get($con);
		
        if ($querydb &&
            $this->parentNode === null && 
            !$this->isRootNode() &&
            !$this->obj->isNew() && 
            !$this->obj->isDeleted())
        {
            $npath =& $this->getNodePath();
			//strrpos fix
			$sep = 0;
			while(false !== ($last = strpos($npath, <?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP(), $sep))) {
				$sep = $last + strlen(<?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP());
			}
            $ppath = substr($npath, 0, $sep - strlen(<?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP()));

            $criteria =& new Criteria(<?php echo $table->getPhpName() ?>Peer::DATABASE_NAME());
            $criteria->add(<?php echo $table->getPhpName() ?>NodePeer::NPATH_COLNAME(), $ppath, Criteria::EQUAL());

            if ($parentObj =& <?php echo $table->getPhpName() ?>Peer::doSelectOne($criteria, Param::set($con)))
            {
                $parentNode =& new <?php echo $table->getPhpName() ?>Node(Param::set($parentObj));
                $parentNode->attachChildNode($this);
            }
        }
        
        return $this->parentNode;
    }

    /** 
     * Returns an array of all ancestor nodes, starting with the root node 
     * first.
     *
     * @param boolean True if ancestors should be retrieved from database.
     * @param Connection Connection to use if retrieving from database.
     * @return array
     */
    function & getAncestors($querydb = false, $con = null)
    {
		Propel::assertParam($con, '<?php echo $CLASS; ?>', 'getAncestors', 2);
    	$con =& Param::get($con);
		
        $ancestors = array();
        $parentNode = $this;
        
        while ($parentNode =& $parentNode->getParentNode($querydb, Param::set($con)))
            array_unshift($ancestors, $parentNode);
        
        return $ancestors;
    }
    
    /**
     * Returns true if node is the root node of the tree.
     * @return boolean
     */
    function isRootNode()
    {
        return ($this->getNodePath() === '1');
    }

    /**
     * Changes the state of the object and its descendants to 'new'.
     * Also changes the node path to '0' to indicate that it is not a 
     * stored node.
     *
     * @param boolean
     * @return void
     */
    function setNew($b)
    {
        $this->adjustStatus('new', $b);
        $this->adjustNodePath($this->getNodePath(), '0');
    }
    
    /**
     * Changes the state of the object and its descendants to 'deleted'.
     *
     * @param boolean
     * @return void
     */
    function setDeleted($b)
    {
        $this->adjustStatus('deleted', $b);
    }
     
    /**
     * Adds the specified node (and its children) as a child to this node. If a
     * valid $beforeNode is specified, the node will be inserted in front of 
     * $beforeNode. If $beforeNode is not specified the node will be appended to
     * the end of the child nodes.
     *
     * @param <?php echo $table->getPhpName() ?>Node Node to add.
     * @param <?php echo $table->getPhpName() ?>Node Node to insert before.
     * @param Connection Connection to use.
     */
    function addChildNode(&$node, $beforeNode = null, $con = null)
    {
		Propel::assertParam($beforeNode, '<?php echo $CLASS; ?>', 'addChildNode', 2);
		Propel::assertParam($con, '<?php echo $CLASS; ?>', 'addChildNode', 3);
    	$beforeNode =& Param::get($beforeNode);
    	$con =& Param::get($con);

        if ($this->obj->isNew() && !$node->obj->isNew())
            return new PropelException(PROPEL_ERROR, 'Cannot add stored nodes to a new node.');
            
        if ($this->obj->isDeleted() || $node->obj->isDeleted())
            return new PropelException(PROPEL_ERROR, 'Cannot add children in a deleted state.');
        
        if ($this->hasChildNode($node))
            return new PropelException(PROPEL_ERROR, 'Node is already a child of this node.');

        if ($beforeNode && !$this->hasChildNode($beforeNode))
            return new PropelException(PROPEL_ERROR, 'Invalid beforeNode.');
            
        if ($con === null)
            $con =& Propel::getConnection(<?php echo $table->getPhpName() ?>Peer::DATABASE_NAME());
            
        if (Propel::isError($con))
            return $con;

        if (!$this->obj->isNew()) {
          $e = $con->begin();
          if (Creole::isError($e)) { $con->rollback(); return new PropelException(PROPEL_ERROR_DB, $e); }
        }

        if ($beforeNode)
        {
            // Inserting before a node.
            $childIdx = $beforeNode->getNodeIndex();
            $e = $this->shiftChildNodes(1, $beforeNode->getNodeIndex(), $con);
            if (Propel::isError($e)) { $con->rollback(); return $e; }
        }
        else
        {
            // Appending child node.
            if ($lastNode =& $this->getLastChildNode(true, Param::set($con)))
                $childIdx = $lastNode->getNodeIndex()+1;
            else
                $childIdx = 1;
        }

        // Add the child (and its children) at the specified index.

        if (!$this->obj->isNew() && $node->obj->isNew())
        {
            $e = $this->insertNewChildNode($node, $childIdx, $con);
            if (Propel::isError($e)) { $con->rollback(); return $e; }
        }
        else
        {
            // $this->isNew() && $node->isNew() ||
            // !$this->isNew() && !node->isNew()
                
            $srcPath = $node->getNodePath();
            $dstPath = $this->getNodePath() . <?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP() . $childIdx;
                
            if (!$node->obj->isNew())
            {
                $e = <?php echo $table->getPhpName() ?>NodePeer::moveNodeSubTree($srcPath, $dstPath, Param::set($con));
                if (Propel::isError($e)) { $con->rollback(); return $e; }

                $parentNode =& $node->getParentNode(true, Param::set($con));
            }
            else
            {
                $parentNode =& $node->getParentNode();
            }

            if ($parentNode)
            {
                $parentNode->detachChildNode($node);
                $e = $parentNode->shiftChildNodes(-1, $node->getNodeIndex()+1, $con);
                if (Propel::isError($e)) { $con->rollback(); return $e; }
            }
            
            $node->adjustNodePath($srcPath, $dstPath);
        }

        if (!$this->obj->isNew()) {
            $e = $con->commit();
            if (Creole::isError($e)) { return new PropelException(PROPEL_ERROR_DB, $e); }
        }

        $this->attachChildNode($node);
    }

    /**
     * Moves the specified child node in the specified direction.
     *
     * @param <?php $table->getPhpName() ?>Node Node to move.
     * @param int Number of spaces to move among siblings (may be negative).
     * @param Connection Connection to use.
     * @throws PropelException
     */
    function moveChildNode(&$node, $direction, $con = null)
    {
		Propel::assertParam($con, '<?php echo $CLASS; ?>', 'moveChildNode', 3);
		$con =& Param::get($con);
        return new PropelException(PROPEL_ERROR, 'moveChildNode() not implemented yet.');
    }
    
    /**
     * Saves modified object data to the datastore.
     *
     * @param boolean If true, descendants will be saved as well.
     * @param Connection Connection to use.
     */
    function save($recurse = false, $con = null)
    {
		Propel::assertParam($con, '<?php echo $CLASS; ?>', 'save', 2);
		$con =& Param::get($con);

        if ($this->obj->isDeleted())
            return new PropelException(PROPEL_ERROR, 'Cannot save deleted node.');
            
        if (substr($this->getNodePath(), 0, 1) == '0')
            return new PropelException(PROPEL_ERROR, 'Cannot save unattached node.');

        if ($this->obj->isColumnModified(<?php echo $table->getPhpName() ?>NodePeer::NPATH_COLNAME()))
            return new PropelException(PROPEL_ERROR, 'Cannot save manually modified node path.');
        
        $this->obj->save(Param::set($con));
        
        if ($recurse)
        {
            foreach ($this->childNodes as $key => $childNode)
                $this->childNodes[$key]->save($recurse, Param::set($con));
        }
    }
    
    /**
     * Removes this object and all descendants from datastore.
     *
     * @param Connection Connection to use.
     * @return void
     * @throws PropelException
     */
    function delete($con = null)
    {
		Propel::assertParam($con, '<?php echo $CLASS; ?>', 'delete', 1);
		$con =& Param::get($con);

        if ($this->obj->isDeleted())
            return new PropelException(PROPEL_ERROR, 'This node has already been deleted.');

        if (!$this->obj->isNew())
        {
            <?php echo $table->getPhpName() ?>NodePeer::deleteNodeSubTree($this->getNodePath(), Param::set($con));
        }
        
        if ($parentNode =& $this->getParentNode(true, Param::set($con)))
        {
            $parentNode->detachChildNode($this);
            $parentNode->shiftChildNodes(-1, $this->getNodeIndex()+1, $con);
        }
        
        $this->setDeleted(true);
    }

    /**
     * Compares the object wrapped by this node with that of another node. Use 
     * this instead of equality operators to prevent recursive dependency 
     * errors.
     *
     * @param <?php echo $table->getPhpName() ?>Node Node to compare.
     * @param boolean True if strict comparison should be used.
     * @return boolean
     */
    function equals(&$node, $strict = false)
    {
        if ($strict)
            return ($this->obj === $node->obj);
        else
            return ($this->obj == $node->obj);
    }

    /**
     * This method is used internally when constructing the tree structure 
     * from the database. To set the parent of a node, you should call 
     * addChildNode() on the parent.
     * @param <?php echo $table->getPhpName() ?>Node Parent node to attach.
     * @return void
     * @throws PropelException
     */
    function attachParentNode(&$node)
    {
        if (!$node->hasChildNode($this, true))
            return new PropelException(PROPEL_ERROR, 'Failed to attach parent node for non-child.');

        $this->parentNode =& $node;
    }

    /**
     * This method is used internally when constructing the tree structure 
     * from the database. To add a child to a node you should call the 
     * addChildNode() method instead. 
     *
     * @param <?php echo $table->getPhpName() ?>Node Child node to attach.
     * @return void
     * @throws PropelException
     */
    function attachChildNode(&$node)
    {
        if ($this->hasChildNode($node))
            return new PropelException(PROPEL_ERROR, 'Failed to attach child node. Node already exists.');
        
        if ($this->obj->isDeleted() || $node->obj->isDeleted())
            return new PropelException(PROPEL_ERROR, 'Failed to attach node in deleted state.');
            
        if ($this->obj->isNew() && !$node->obj->isNew())
            return new PropelException(PROPEL_ERROR, 'Failed to attach non-new child to new node.');

        if (!$this->obj->isNew() && $node->obj->isNew())
            return new PropelException(PROPEL_ERROR, 'Failed to attach new child to non-new node.');

        if ($this->getNodePath() . <?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP() . $node->getNodeIndex() != $node->getNodePath())
            return new PropelException(PROPEL_ERROR, 'Failed to attach child node. Node path mismatch.');
        
        $this->childNodes[$node->getNodeIndex()] =& $node;
        ksort($this->childNodes);
        
        $node->attachParentNode($this);
    }

    /**
     * This method is used internally when deleting nodes. It is used to break
     * the link to this node's parent.
     * @param <?php echo $table->getPhpName() ?>Node Parent node to detach from.
     * @return void
     * @throws PropelException
     */
    function detachParentNode(&$node)
    {
        if (!$node->hasChildNode($this, true))
            return new PropelException(PROPEL_ERROR, 'Failed to detach parent node from non-child.');

        unset($node->childNodes[$this->getNodeIndex()]);
        $this->parentNode = null;
    }
    
    /**
     * This method is used internally when deleting nodes. It is used to break
     * the link to this between this node and the specified child.
     * @param <?php echo $table->getPhpName() ?>Node Child node to detach.
     * @return void
     * @throws PropelException
     */
    function detachChildNode(&$node)
    {
        if (!$this->hasChildNode($node, true))
            return new PropelException(PROPEL_ERROR, 'Failed to detach non-existent child node.');

        $this->childNodes[$node->getNodeIndex()] = & Propel::null();
        unset($this->childNodes[$node->getNodeIndex()]);
        $node->parentNode =& Propel::null();
    }
    
    /**
     * Shifts child nodes in the specified direction and offset index. This 
     * method assumes that there is already space available in the 
     * direction/offset indicated. 
     *
     * @param int Direction/# spaces to shift. 1=leftshift, 1=rightshift
     * @param int Node index to start shift at.
     * @param Connection The connection to be used.
     * @return void
     * @throws PropelException
     */
    function shiftChildNodes($direction, $offsetIdx, &$con)
    {
        if ($this->obj->isDeleted())
            return new PropelException(PROPEL_ERROR, 'Cannot shift nodes for deleted object');

        $lastNode =& $this->getLastChildNode(true, Param::set($con));
        $lastIdx = ($lastNode !== null ? $lastNode->getNodeIndex() : 0);

        if ($lastNode === null || $offsetIdx > $lastIdx)
            return;

        if ($con === null)
            $con =& Propel::getConnection(<?php echo $table->getPhpName() ?>Peer::DATABASE_NAME());

        if (Propel::isError($con)) {
                return $con;
        }

        if (!$this->obj->isNew())
        {
            // Shift nodes in database.

            $e = $con->begin();
            if (Creole::isError($e)) { $con->rollback(); return new PropelException(PROPEL_ERROR_DB, $e); }

            $n = $lastIdx - $offsetIdx + 1;
            $i = $direction < 1 ? $offsetIdx : $lastIdx;

            while ($n--)
            {
                $srcPath = $this->getNodePath() . <?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP() . $i;              // 1.2.2
                $dstPath = $this->getNodePath() . <?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP() . ($i+$direction); // 1.2.3

                $e = <?php echo $table->getPhpName() ?>NodePeer::moveNodeSubTree($srcPath, $dstPath, Param::set($con));
                if (Propel::isError($e)) { $con->rollback(); return $e; }

                $i -= $direction;
            }

            $e = $con->commit();
            if (Creole::isError($e)) { $con->rollback(); return new PropelException(PROPEL_ERROR_DB, $e); }
        }
        
        // Shift the in-memory objects.
        
        $n = $lastIdx - $offsetIdx + 1;
        $i = $direction < 1 ? $offsetIdx : $lastIdx;

        while ($n--)
        {
            if (isset($this->childNodes[$i]))
            {
                $srcPath = $this->getNodePath() . <?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP() . $i;              // 1.2.2
                $dstPath = $this->getNodePath() . <?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP() . ($i+$direction); // 1.2.3
                
                $this->childNodes[$i+$direction] =& $this->childNodes[$i];
                $this->childNodes[$i+$direction]->adjustNodePath($srcPath, $dstPath);

                unset($this->childNodes[$i]);
            }
            
            $i -= $direction;
        }
        
        ksort($this->childNodes);
    }
    
    /**
     * Inserts the node and its children at the specified childIdx.
     *
     * @param <?php echo $table->getPhpName() ?>Node Node to insert.
     * @param int One-based child index to insert at.
     * @param Connection Connection to use.
     * @param void
     */
    function insertNewChildNode(&$node, $childIdx, &$con)
    {
        if (!$node->obj->isNew())
            return new PropelException(PROPEL_ERROR, 'Failed to insert non-new node.');

        $setNodePath = "set" . <?php echo $table->getPhpName() ?>NodePeer::NPATH_PHPNAME();

        $node->obj->$setNodePath($this->getNodePath() . <?php echo $table->getPhpName() ?>NodePeer::NPATH_SEP() . $childIdx);
        $node->obj->save(Param::set($con));
        
        $i = 1;
        foreach($node->childNodes as $key => $childNode)
            $node->insertNewChildNode($node->childNodes[$key], $i++, $con);
    }

    /**
     * Adjust new/deleted status of node and all children. 
     *
     * @param string Status to change ('New' or 'Deleted')
     * @param boolean Value for status.
     * @return void
     */
    function adjustStatus($status, $b)
    {
        $setStatus = 'set' . $status;
        
        $this->obj->$setStatus($b);
        
        foreach ($this->childNodes as $key => $childNode)
            $this->childNodes[$key]->obj->$setStatus($b);
    }
    
    /**
     * Adjust path of node and all children. This is used internally when 
     * inserting/moving nodes.
     *
     * @param string Section of old path to change.
     * @param string New section to replace old path with.
     * @return void
     */
    function adjustNodePath($oldBasePath, $newBasePath)
    {
        $setNodePath = "set" . <?php echo $table->getPhpName() ?>NodePeer::NPATH_PHPNAME();
        
        $this->obj->$setNodePath($newBasePath . 
                                 substr($this->getNodePath(), strlen($oldBasePath)));
        $this->obj->resetModified(<?php echo $table->getPhpName() ?>NodePeer::NPATH_COLNAME());

        foreach ($this->childNodes as $key => $childNode)
            $this->childNodes[$key]->adjustNodePath($oldBasePath, $newBasePath);
    }

}

?>