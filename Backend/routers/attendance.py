from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from database import get_db
from models import Attendance
from services.sheets_service import update_google_sheet
from services.sheets_service import (
    update_google_sheet,
    sheet
)
from datetime import datetime
from zoneinfo import ZoneInfo

def get_ist_time():
    return datetime.now(
        ZoneInfo("Asia/Kolkata")
    ).time()

router = APIRouter(tags=["Attendance"])


@router.post("/checkin")
def check_in(
    db: Session = Depends(get_db)
):

    existing_record = (
        db.query(Attendance)
        .filter(
            Attendance.date == date.today()
        )
        .first()
    )

    if existing_record:
        return {
            "error": "Already checked in today"
        }

    attendance = Attendance(
    date=date.today(),
    check_in=get_ist_time(),
    approved=False
)

    db.add(attendance)
    db.commit()
    db.refresh(attendance)

    update_google_sheet(attendance)

    return {
        "message": "Check In Successful",
        "date": str(attendance.date),
        "check_in": str(attendance.check_in)
    }


@router.post("/checkout")
def check_out(
    db: Session = Depends(get_db)
):

    attendance = (
        db.query(Attendance)
        .filter(
            Attendance.date == date.today()
        )
        .first()
    )

    if not attendance:
        return {
            "error": "Check in first"
        }

    if attendance.check_out:
        return {
            "error": "Already checked out"
        }

    attendance.check_out = get_ist_time()

    db.commit()
    db.refresh(attendance)

    update_google_sheet(attendance)

    return {
        "message": "Check Out Successful",
        "check_out": str(attendance.check_out)
    }


@router.post("/approve")
def approve_attendance(
    db: Session = Depends(get_db)
):

    attendance = (
        db.query(Attendance)
        .filter(
            Attendance.date == date.today()
        )
        .first()
    )

    if not attendance:
        return {
            "error": "No attendance record found"
        }

    attendance.approved = True

    db.commit()

    update_google_sheet(attendance)

    return {
        "message": "Attendance Approved and Excel Updated"
    }


@router.get("/today")
def get_today_attendance(
    db: Session = Depends(get_db)
):

    attendance = (
        db.query(Attendance)
        .filter(
            Attendance.date == date.today()
        )
        .first()
    )

    return attendance


@router.get("/attendance")
def get_all_attendance(
    db: Session = Depends(get_db)
):

    return db.query(Attendance).all()


@router.post("/test-excel")
def test_excel(
    db: Session = Depends(get_db)
):

    attendance = (
        db.query(Attendance)
        .filter(
            Attendance.date == date.today()
        )
        .first()
    )

    if not attendance:
        return {
            "error": "No attendance record found"
        }

    update_google_sheet(attendance)

    return {
        "message": "Excel Updated Successfully"
    }

@router.get("/status")
def status(
    db: Session = Depends(get_db)
):
    attendance = (
        db.query(Attendance)
        .filter(
            Attendance.date == date.today()
        )
        .first()
    )

    if not attendance:
        return {
            "checked_in": False
        }

    return {
        "checked_in": True,
        "check_in": attendance.check_in,
        "check_out": attendance.check_out,
        "approved": attendance.approved
    }

from datetime import date

@router.delete("/reset")
def reset_today(
    db: Session = Depends(get_db)
):

    attendance = (
        db.query(Attendance)
        .filter(
            Attendance.date == date.today()
        )
        .first()
    )

    if attendance:
        db.delete(attendance)
        db.commit()

    return {
        "message": "Today's attendance cleared"
    }

from fastapi.responses import FileResponse

@router.get("/download-excel")
def download_excel():

    return FileResponse(
        path="/home/utkarsh/attendance-app/AttendaceApp/Intern Attendance Sheet Format __ Utkarsh.xlsx",
        filename="attendance.xlsx",
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )

@router.delete("/delete-today")
def delete_today(
    db: Session = Depends(get_db)
):

    attendance = (
        db.query(Attendance)
        .filter(
            Attendance.date == date.today()
        )
        .first()
    )

    if not attendance:
        return {
            "message":
            "No attendance found"
        }

    row = attendance.date.day + 1

    sheet.update(f"C{row}", [[""]])
    sheet.update(f"D{row}", [[""]])
    sheet.update(f"F{row}", [[""]])
    sheet.update(f"G{row}", [[""]])

    db.delete(attendance)
    db.commit()

    return {
        "message":
        "Attendance deleted"
    }

@router.get("/debug")
def debug(
    db: Session = Depends(get_db)
):

    records = (
        db.query(Attendance)
        .all()
    )

    return [
        {
            "id": record.id,
            "date": str(record.date),
            "check_in": str(record.check_in),
            "check_out": str(record.check_out),
            "approved": record.approved,
        }
        for record in records
    ]