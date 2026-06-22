import gspread
from google.oauth2.service_account import Credentials

SCOPES = [
    "https://www.googleapis.com/auth/spreadsheets",
    "https://www.googleapis.com/auth/drive"
]

creds = Credentials.from_service_account_file(
    "credentials.json",
    scopes=SCOPES,
)

client = gspread.authorize(creds)

sheet = client.open_by_key(
    "1pGoso1_CX2tgA-UF8Wl276qD8oVjSp7SU62cx9pT3Sg"
).sheet1


from datetime import datetime


def update_google_sheet(attendance):

    print("GOOGLE SHEET UPDATE CALLED")

    try:

        row = attendance.date.day + 1

        # Format check-in/out as HH:MM
        check_in = (
            attendance.check_in.strftime("%H:%M")
            if attendance.check_in
            else ""
        )

        check_out = (
            attendance.check_out.strftime("%H:%M")
            if attendance.check_out
            else ""
        )

        # Check In
        sheet.update(
            f"C{row}",
            [[check_in]]
        )

        # Check Out
        sheet.update(
            f"D{row}",
            [[check_out]]
        )

        
        # Status
        sheet.update(
            f"F{row}",
            [["Present"]]
        )

        # Approved
        sheet.update(
            f"G{row}",
            [[
                "Yes"
                if attendance.approved
                else "No"
            ]]
        )

        print(f"UPDATED ROW {row}")

    except Exception as e:

        print(
            "GOOGLE SHEET ERROR:",
            e
        )