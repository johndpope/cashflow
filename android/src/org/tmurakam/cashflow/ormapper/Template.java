// Generated by O/R mapper generator ver 0.1(cashflow)

package org.tmurakam.cashflow.ormapper;

import java.util.ArrayList;
import android.content.ContentValues;
import android.database.*;
import android.database.sqlite.*;

import org.tmurakam.cashflow.ormapper.ORRecord;

public class Template extends ORRecord {
	public long pid;
    public int asset;
    public int dst_asset;
    
    private boolean isInserted = false;

    /**
      @brief Migrate database table
      @return YES - table was newly created, NO - table already exists
    */
    static boolean migrate() {
        String[] columnTypes = {
        "asset", "INTEGER",
        "dst_asset", "INTEGER",
        "date", "DATE",
        "type", "INTEGER",
        "category", "INTEGER",
        "value", "REAL",
        "description", "TEXT",
        "memo", "TEXT",
        };

        return migrate(columnTypes);
    }

    /**
       @brief allocate entry
    */
    public static Template allocator() {
        return new Template();
    }

    // Read Operations

    /**
       @brief get the record matchs the id

       @param pid Primary key of the record
       @return record
    */
    public static Template find(int pid) {
        SQLiteDatabase db = Database.instance();

        String[] param = { Integer.toString(pid) };
        Cursor cursor = db.rawQuery("SELECT * FROM Transactions WHERE key = ?;", param);

        Template e = null;
        cursor.moveToFirst();
        if (!cursor.isAfterLast()) {
            e = allocator();
            e._loadRow(cursor);
        }
        cursor.close();
 
        return e;
    }

    /**
       @brief get all records matche the conditions

       @param cond Conditions (WHERE phrase and so on)
       @return array of records
    */
    public static ArrayList<Template> find_cond(String cond) {
        return find_cond(cond, null);
    }

    public static ArrayList<Template> find_cond(String cond, String[] param) {
        String sql;
        sql = "SELECT * FROM Transactions";
        if (cond != null) {
            sql += " ";
            sql += cond;
        }
        SQLiteDatabase db = Database.instance();
        Cursor cursor = db.rawQuery(sql, param);
        cursor.moveToFirst();

        ArrayList<Template> array = new ArrayList<Template>();

        while (!cursor.isAfterLast()) {
            Template e = allocator();
            e._loadRow(cursor);
            array.add(e);
        }
        return array;
    }

    private void _loadRow(Cursor cursor) {
        this.pid = cursor.getInt(0);
        // TBD

        isInserted = true;
    }

    // Create operations

    public void insert() {
        super.insert();

        SQLiteDatabase db = Database.instance();

        this.pid = db.insert("Transactions", "asset", getContentValues());

        //[db commitTransaction];
        isInserted = true;
    }

    // Update operations

    public void update() {
        super.update();

        SQLiteDatabase db = Database.instance();
        //[db beginTransaction];

        ContentValues cv = getContentValues();
        // TBD...

        String[] whereArgs = { Long.toString(pid) };
        db.update("Transactions", cv, "WHERE key = ?", whereArgs);

        //[db commitTransaction];
    }

    private ContentValues getContentValues()
    {
        ContentValues cv = new ContentValues(8);
        cv.put("asset", asset);
        cv.put("dst_asset", dst_asset);
        // TBD...
        
        return cv;
    }


    // Delete operations

    /**
       @brief Delete record
    */
    public void delete() {
        SQLiteDatabase db = Database.instance();

        String[] whereArgs = { Long.toString(pid) };
        db.delete("Transactions", "WHERE key = ?", whereArgs);
    }

    /**
       @brief Delete all records
    */
    public void delete_cond(String cond) {
        SQLiteDatabase db = Database.instance();

        if (cond == null) {
            cond = "";
        }
        String sql = "DELETE FROM Transactions " + cond;
        db.execSQL(sql);
    }

    // Internal functions

    public static String tableName() {
        return "Transactions";
    }
}
