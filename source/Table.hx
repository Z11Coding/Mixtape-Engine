class DTable<T>
{
	private var table:Array<Array<T>>;
	private var rows:Int;
	private var cols:Int;

	public inline function new(rows:Int, cols:Int)
	{
		this.rows = rows;
		this.cols = cols;
		table = [];
		for (i in 0...rows)
		{
			var row:Array<T> = [];
			for (j in 0...cols) {
				row.push(cast null);
			}
			table.push(row);
		}
	}

	public function fromArray(array:Array<Array<T>>):Void
	{
		this.rows = array.length;
		this.cols = array[0].length;
		this.table = array;
	}

	public function getCell(row:Int, col:Int):T
	{
		return table[row][col];
	}

	public function setCell(row:Int, col:Int, value:T):Void
	{
		table[row][col] = value;
	}

	public function getByLinearIndex(index:Int):T
	{
		var row = index / cols;
		var col = index % cols;
        return table[Std.int(row)][Std.int(col)];
	}

	public function getRow(row:Int):Array<T>
	{
		return table[row];
	}

	public function getColumn(col:Int):Array<T>
	{
		var column:Array<T> = [];
		for (i in 0...rows)
		{
			column.push(table[i][col]);
		}
		return column;
	}

    private function formatCell(value:T):String
    {
        var str = Std.string(value);
        if (str.length > 5) {
            str = str.substr(0, 2) + "..." + str.substr(str.length - 1, 1);
        }
        return StringTools.lpad(str, " ", 5);
    }

    public function toString():String
    {
        var result = "";
        result = "[" + "Rows: " + rows + ", Cols: " + cols + "]" + "\n";
        for (row in table)
        {
            for (cell in row)
            {
                result += formatCell(cell) + " ";
            }
            result = result.substr(0, result.length - 1) + "\n";
        }
        return result.replace("null", "-");
    }

	// public function toString():String
	// {
	// 	var result = "";

    //     result = "["+ "Rows: " + rows + ", Cols: " + cols + "]"+ "\n";
	// 	for (row in table)
	// 	{
	// 		result += row.join(", ") + "\n";
	// 	}

    //     // result.replace("null", "-");
	// 	return result.replace("null", "-");
	// }

	public function fromString(str:String):Void
	{
		var rows:Array<String> = str.split("\n");
		this.rows = rows.length;
		this.cols = rows[0].split(", ").length;
		table = [];
		for (i in 0...rows.length)
		{
            var row:Array<T> = rows[i].split(", ").map(function(item) return cast item);
            table.push(row);
		}
	}

	public function toArray():Array<Array<T>>
	{
		return table;
	}

	public function fromMap(map:Map<String, Dynamic>):Void
	{
		this.rows = map.get("rows");
		this.cols = map.get("cols");
		table = [];
		for (i in 0...rows)
		{
			table.push(map.get("row_" + i));
		}
	}

	public function toMap():Map<String, Dynamic>
	{
		var map:Map<String, Dynamic> = new Map<String, Dynamic>();
		map.set("rows", rows);
		map.set("cols", cols);
		for (i in 0...rows)
		{
			map.set("row_" + i, table[i]);
		}
		return map;
	}

	public function fromObject(obj:Dynamic):Void
	{
		this.rows = obj.rows;
		this.cols = obj.cols;
		table = [];
		for (i in 0...rows)
		{
			table.push(obj[Std.parseInt("row_" + i)]);
		}
	}

	public function toObject():Dynamic
	{
		var obj:Dynamic = {rows: rows, cols: cols};
		for (i in 0...rows)
		{
			obj[Std.parseInt("row_" + i)] = table[i];
		}
		return obj;
	}
}

@:allow(HTable)
class Cell<T>
{
	public var data:Array<T>;
	public var type:String;
	public var rawInfo:String;
	public var byteData:String;
	public var addressInfo:String;
	public var internalVars:Dynamic;

	public function new(value:T)
	{
		this.data = [value];
		this.type = Type.getClassName(Type.getClass(value));
		this.rawInfo = Std.string(value);
		this.byteData = haxe.crypto.Base64.encode(haxe.io.Bytes.ofString(Std.string(value)));
		this.addressInfo = "Address: " + Std.string(this);
		this.internalVars = {};
	}

	public function getValue():T
	{
		return data[0];
	}

	public function setValue(value:T):Void
	{
		data[0] = value;
		this.rawInfo = Std.string(value);
		this.byteData = haxe.crypto.Base64.encode(haxe.io.Bytes.ofString(Std.string(value)));
	}
}

class HTable<T>
{
	private var table:Array<Array<Cell<T>>>;
	private var rows:Int;
	private var cols:Int;

	public inline function new(rows:Int, cols:Int)
	{
		this.rows = rows;
		this.cols = cols;
		table = [];
		for (i in 0...rows)
		{
			var row:Array<Cell<T>> = [];
			for (j in 0...cols)
			{
				row.push(new Cell<T>(null));
			}
			table.push(row);
		}
	}

	public function fromArray(array:Array<Array<T>>):Void
	{
		this.rows = array.length;
		this.cols = array[0].length;
		this.table = [];
		for (i in 0...rows)
		{
			var row:Array<Cell<T>> = [];
			for (j in 0...cols)
			{
				row.push(new Cell<T>(array[i][j]));
			}
			table.push(row);
		}
	}

	public function getCell(row:Int, col:Int):Cell<T>
	{
		return table[row][col];
	}

    public function getCellValue(row:Int, col:Int):T
    {
        return table[row][col].getValue();
    }

	public function setCell(row:Int, col:Int, value:T):Void
	{
		table[row][col].setValue(value);
	}

	public function getByLinearIndex(index:Int):Cell<T>
	{
		var row = index / cols;
		var col = index % cols;
        return table[Std.int(row)][Std.int(col)];
	}

	public function getRow(row:Int):Array<Cell<T>>
	{
		return table[row];
	}

	public function getColumn(col:Int):Array<Cell<T>>
	{
		var column:Array<Cell<T>> = [];
		for (i in 0...rows)
		{
			column.push(table[i][col]);
		}
		return column;
	}

	public function toString():String
	{
		var result = "";
            
            result = "["+ "Rows: " + rows + ", Cols: " + cols + "]"+ "\n";
            result += "Type: " + Type.getClassName(Type.getClass(table[0][0].getValue())) + "\n";
            result += "Raw Info: " + table[0][0].rawInfo + "\n";
            result += "Byte Data: " + table[0][0].byteData + "\n";
            result += "Address Info: " + table[0][0].addressInfo + "\n";
            result += "Internal Vars: " + Std.string(table[0][0].internalVars) + "\n";
            result += "[" + "\n";

		for (row in table)
		{
			for (cell in row)
			{
				result += cell.getValue() + ", ";
			}
			result = result.substr(0, result.length - 2) + "\n";
		}

        // result = result.substr(0, result.length - 1);

		return result.replace("null", "-");
	}

	public function fromString(str:String):Void
	{
		var rows:Array<String> = str.split("\n");
		this.rows = rows.length;
		this.cols = rows[0].split(", ").length;
		table = [];
		for (i in 0...rows.length)
		{
			var row:Array<Cell<T>> = [];
			var values:Array<String> = rows[i].split(", ");
			for (j in 0...values.length)
			{
				row.push(new Cell<T>(cast values[j]));
			}
			table.push(row);
		}
	}

	public function toArray():Array<Array<T>>
	{
		var array:Array<Array<T>> = [];
		for (row in table)
		{
			var arrRow:Array<T> = [];
			for (cell in row)
			{
				arrRow.push(cell.getValue());
			}
			array.push(arrRow);
		}
		return array;
	}

	public function fromMap(map:Map<String, Dynamic>):Void
	{
		this.rows = map.get("rows");
		this.cols = map.get("cols");
		table = [];
		for (i in 0...rows)
		{
			var row:Array<Cell<T>> = [];
			for (j in 0...cols)
			{
				row.push(new Cell<T>(map.get("row_" + i + "_col_" + j)));
			}
			table.push(row);
		}
	}

	public function toMap():Map<String, Dynamic>
	{
		var map:Map<String, Dynamic> = new Map<String, Dynamic>();
		map.set("rows", rows);
		map.set("cols", cols);
		for (i in 0...rows)
		{
			for (j in 0...cols)
			{
				map.set("row_" + i + "_col_" + j, table[i][j].getValue());
			}
		}
		return map;
	}

	public function fromObject(obj:Dynamic):Void
	{
		this.rows = obj.rows;
		this.cols = obj.cols;
		table = [];
		for (i in 0...rows)
		{
			var row:Array<Cell<T>> = [];
			for (j in 0...cols)
			{
				row.push(new Cell<T>(obj[arrayStack("row_" + i + "_col_" + j)]));
			}
			table.push(row);
		}
	}

	public function toObject():Dynamic
	{
		var obj:Dynamic = {rows: rows, cols: cols};
		for (i in 0...rows)
		{
			for (j in 0...cols)
			{
				obj[arrayStack("row_" + i + "_col_" + j)] = table[i][j].getValue();
			}
		}
		return obj;
	}

    private function arrayStack(index:String):Dynamic
    {
        return indexToArrayStack(getIndexFromString(index));
    }

	public function getIndexFromString(index:String):{row:Int, col:Int}
	{
		var parts = index.split(",");
		return {row: Std.parseInt(parts[0]), col: Std.parseInt(parts[1])};
	}

	private function indexToArrayStack( ind:Dynamic):Dynamic
	{
		return [Std.parseInt( ind .row)][Std.parseInt( ind .col)];
	}

	public function getValueFromStringIndex(index:String):T
	{
		var parts = index.split("_");
		var row = Std.parseInt(parts[1]);
		var col = Std.parseInt(parts[3]);
		return table[row][col].getValue();
	}
public function getValueFromSecondaryArray(index:String, secondaryArray:Array<Array<T>>):T
{
	var parts = index.split("_");
	var row = Std.parseInt(parts[1]);
	var col = Std.parseInt(parts[3]);
	return secondaryArray[row][col];
}
}
