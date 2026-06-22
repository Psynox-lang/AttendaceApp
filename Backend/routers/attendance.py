from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from database import get_db
from models import Attendance
from services.excel_service import update_excel

from datetime import datetime, date

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
        check_in=datetime.now().time(),
        approved=False
    )

    db.add(attendance)
    db.commit()
    db.refresh(attendance)

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

    attendance.check_out = datetime.now().time()

    db.commit()
    db.refresh(attendance)

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

    update_excel(attendance)

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

    update_excel(attendance)

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