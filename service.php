<?php
		if (($_SERVER["REQUEST_METHOD"] == "POST") and isset($_POST["name"]) and isset($_POST["imageData"])) {
			# Assume valid parameters. Post a new entry to the database.
			if (post_data($_POST["name"], $_POST["imageData"]) === False){
				echo "fail";
			} else{
				echo "success";
			}
		}
		else if ($_SERVER["REQUEST_METHOD"] == "GET"){
			# Return all the database entries
			if (isset($_GET["id"])){ 
				echo json_encode(array('data'=>get_image($_GET["id"])));
			}else{
				echo json_encode(array('data'=>get_people()));
			}
		}
		else{
			echo "other\n";
			echo $_POST["name"];	
		}

		# This function returns False on failure
		function post_data($name, $imageData){
			$servername = "thenamegame.c1toipdslaff.us-east-1.rds.amazonaws.com";
			$username = "HooWebService";
			$password = "hooWebService1";
			$db_name = "NameGame";
			$retVal = True;
			// Create connection
			$connectionInfo = array("Database"=>$db_name, "UID"=>$username, "PWD"=>$password);
			$conn = sqlsrv_connect( $servername, $connectionInfo);

			if( $conn ) {
				$sqlQuery = "INSERT INTO People(name, picture) VALUES (?,?)";
				$postPerson = sqlsrv_query($conn, $sqlQuery, array($name, $imageData));
				if ($postPerson === false){
					$retVal = False;
				}else{
					# successful post
					/* Free the statement and connection resources. */
					sqlsrv_free_stmt($postPerson);
				}
     			sqlsrv_close( $conn );
			}else{
     				$retVal = False;
			}

			return $retVal;
		}

		function get_people(){
			$servername = "thenamegame.c1toipdslaff.us-east-1.rds.amazonaws.com";
			$username = "HooWebService";
			$password = "hooWebService1";
			$db_name = "NameGame";
			$retVal = array();
			
			// Create connection
			$connectionInfo = array("Database"=>$db_name, "UID"=>$username, "PWD"=>$password);
			$conn = sqlsrv_connect( $servername, $connectionInfo);

			if( $conn ) {
				$sqlQuery = "SELECT ID,name FROM People";

				/*Execute the query with a scrollable cursor so
				we can determine the number of rows returned.*/
				$cursorType = array("Scrollable" => SQLSRV_CURSOR_KEYSET);
				$getPeople = sqlsrv_query($conn, $sqlQuery, NULL, $cursorType);
				if ( $getPeople === false){
					echo "fail\n";
				}else{
					if(sqlsrv_has_rows($getPeople)){
						$rowCount = sqlsrv_num_rows($getPeople);
						#echo "\n" . $rowCount . "\n";
						while( $row = sqlsrv_fetch_array( $getPeople, SQLSRV_FETCH_ASSOC)){
							array_push($retVal, array($row[ID]=>$row[name]));
						}
					}
					/* Free the statement and connection resources. */
					sqlsrv_free_stmt( $getPeople );
				}
     			sqlsrv_close( $conn );
			}else{
     				echo "Connection could not be established.<br />";
     				die( print_r( sqlsrv_errors(), true));
			}

			return $retVal;
		}

		function get_image($picID){
			$servername = "thenamegame.c1toipdslaff.us-east-1.rds.amazonaws.com";
			$username = "HooWebService";
			$password = "hooWebService1";
			$db_name = "NameGame";
			$retVal = "";
			
			// Create connection
			$connectionInfo = array("Database"=>$db_name, "UID"=>$username, "PWD"=>$password);
			$conn = sqlsrv_connect( $servername, $connectionInfo);

			if( $conn ) {
				$sqlQuery = "SELECT picture FROM People WHERE ID = ?";

				/*Execute the query with a scrollable cursor so
				we can determine the number of rows returned.*/
				$cursorType = array("Scrollable" => SQLSRV_CURSOR_KEYSET);
				$getPicture = sqlsrv_query($conn, $sqlQuery, array($picID), $cursorType);
				if ( $getPicture === false){
					echo "fail\n";
				}else{
					if(sqlsrv_has_rows($getPicture)){
						# row count should always be 1 since ID is a primary key
						$rowCount = sqlsrv_num_rows($getPeople);
						#echo "\n" . $rowCount . "\n";
						while( $row = sqlsrv_fetch_array( $getPicture, SQLSRV_FETCH_ASSOC)){
							$retVal = $row["picture"];
						}
					}
					/* Free the statement and connection resources. */
					sqlsrv_free_stmt( $getPeople );
				}
     			sqlsrv_close( $conn );
			}else{
     				echo "Connection could not be established.<br />";
     				die( print_r( sqlsrv_errors(), true));
			}

			return $retVal;
		}
?>